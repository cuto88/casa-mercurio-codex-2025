# ops\synch_ha.ps1
# Sync repo -> Home Assistant config (Z:\config)
# Robust, no placeholders, no YAML-related stuff here.

[CmdletBinding()]
param(
  [string]$HaRoot = "Z:\",
  [switch]$DryRun,
  [switch]$IncludeWWW
)

$ErrorActionPreference = "Stop"

function TS { (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") }
function Log([string]$msg, [string]$color = "Gray") { Write-Host "[$(TS)] $msg" -ForegroundColor $color }

# Repo root = parent of ops\
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..") | Select-Object -ExpandProperty Path

if (-not (Test-Path $HaRoot)) {
  Log "ERRORE: HA root non trovato: $HaRoot" "Red"
  exit 2
}

Log "RepoRoot: $RepoRoot" "Cyan"
Log "HaRoot  : $HaRoot" "Cyan"
Log ("Modalità: " + ($(if ($DryRun) { "DRY-RUN" } else { "LIVE" }))) "Yellow"

# Cosa syncare verso HA
$FoldersToSync = @(
  "packages",
  "mirai",
  "logica",
  "lovelace",
  "custom_components",
  "blueprints",
  "deps",
  "export",
  "tts"
)

if ($IncludeWWW) { $FoldersToSync += "www" }

# File root da syncare (tieni minimale)
$FilesToSync = @(
  "configuration.yaml"
)

# Cosa NON syncare mai
$ExcludeDirs = @(".git", ".github", "tools", "docs", "ops", "__pycache__")
$ExcludeFiles = @("*.disabled", "*.bak", "*.tmp", "*.log", "*.old", "home-assistant*.db*", "*.db-wal", "*.db-shm")

# Robocopy options
$common = @(
  "/MIR",              # mirror
  "/Z",                # restartable
  "/FFT",              # FAT time tolerance (NAS/SMB)
  "/R:2", "/W:2",      # retry
  "/XJ",               # exclude junctions
  "/XO",               # exclude older
  "/XA:SH"             # skip system/hidden
)

if ($DryRun) { $common += "/L" }

foreach ($d in $ExcludeDirs)  { $common += "/XD"; $common += $d }
foreach ($f in $ExcludeFiles) { $common += "/XF"; $common += $f }

$exitCodes = @()

function Run-Robo([string]$src, [string]$dst) {
  if (-not (Test-Path $src)) {
    Log "SKIP (missing): $src" "DarkYellow"
    return 0
  }
  New-Item -ItemType Directory -Force -Path $dst | Out-Null

  Log "SYNC: $src  ->  $dst" "Green"
  $cmd = @("robocopy", $src, $dst) + $common + @("/NFL","/NDL","/NP","/NJH","/NJS")
  & $cmd[0] $cmd[1..($cmd.Count-1)]
  return $LASTEXITCODE
}

# Sync folders
foreach ($folder in $FoldersToSync) {
  $src = Join-Path $RepoRoot $folder
  $dst = Join-Path $HaRoot  $folder
  $code = Run-Robo $src $dst
  $exitCodes += $code
}

# Sync root files
foreach ($file in $FilesToSync) {
  $src = Join-Path $RepoRoot $file
  $dst = Join-Path $HaRoot  $file
  if (Test-Path $src) {
    Log "COPY: $src  ->  $dst" "Green"
    if (-not $DryRun) { Copy-Item -Force $src $dst }
    $exitCodes += 1
  } else {
    Log "SKIP (missing): $src" "DarkYellow"
  }
}

$max = ($exitCodes | Measure-Object -Maximum).Maximum
Log "Robocopy exit codes: $($exitCodes -join ', ')" "Cyan"
Log "Max exit code: $max" "Cyan"

# Robocopy: 0-3 = OK (con differenze/copie), >=8 = errori seri
if ($max -ge 8) {
  Log "SYNC FALLITA (robocopy >= 8). Guarda permessi/lock/path." "Red"
  exit $max
}

Log "SYNC OK." "Green"
exit 0
