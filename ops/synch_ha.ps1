# ops\synch_ha.ps1
# Sync repo -> Home Assistant config (Z:\)
# GitOps: repo is source of truth. Deterministico, niente drift.
# Compatibile PowerShell 5.1

[CmdletBinding()]
param(
  [string]$HaRoot = "Z:\",
  [switch]$DryRun,
  [switch]$IncludeOptionalFolders  # deps/export solo se davvero voluti
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

# === Managed folders (repo -> HA) ===
# www sempre inclusa (HACS frontend + asset tuoi)
$FoldersToSync = @(
  "packages",
  "mirai",
  "logica",
  "lovelace",
  "custom_components",
  "blueprints",
  "www",
  "tts"
)

if ($IncludeOptionalFolders) {
  $FoldersToSync += @("deps", "export")
}

# Root files to sync (keep minimal)
$FilesToSync = @("configuration.yaml")

# Global exclusions (never sync from repo to HA)
$ExcludeDirsGlobal  = @(".git", ".github", "ops", "__pycache__", ".vscode")
$ExcludeFilesGlobal = @("*.bak", "*.tmp", "*.log", "*.old", "home-assistant*.db*", "*.db-wal", "*.db-shm")

# Robocopy options:
# - NO /XO: repo deve sovrascrivere HA se differente (source of truth)
$common = @(
  "/MIR",              # mirror
  "/Z",                # restartable
  "/FFT",              # tolerate NAS/SMB time skew
  "/R:2", "/W:2",      # retry
  "/XJ",               # exclude junctions
  "/XA:SH"             # skip system/hidden
)

if ($DryRun) { $common += "/L" }

function Get-RoboArgs([string]$src, [string]$dst, [string]$folderName) {
  $args = @($src, $dst) + $common + @("/NFL","/NDL","/NP","/NJH","/NJS")

  foreach ($d in $ExcludeDirsGlobal)  { $args += @("/XD", $d) }
  foreach ($f in $ExcludeFilesGlobal) { $args += @("/XF", $f) }

  # Exclude disabled/quarantine folders everywhere
  $args += @("/XD", "_DISABLED_*", "*_DISABLED_*")

  # Folder-specific excludes
  if ($folderName -ieq "logica") {
    # repo-only knowledge/history: keep out of HA runtime
    $args += @("/XD", "logica_backup", "_backup", "backup", "backup_legacy", "archive", "doc")
  }

  return $args
}

$exitCodes = @()

function Run-Robo([string]$src, [string]$dst, [string]$folderName) {
  if (-not (Test-Path $src)) {
    Log "SKIP (missing in repo): $src" "DarkYellow"
    return 0
  }
  New-Item -ItemType Directory -Force -Path $dst | Out-Null

  Log "SYNC: $src  ->  $dst" "Green"
  $args = Get-RoboArgs -src $src -dst $dst -folderName $folderName
  & robocopy @args
  return $LASTEXITCODE
}

# Sync folders
foreach ($folder in $FoldersToSync) {
  $src  = Join-Path $RepoRoot $folder
  $dst  = Join-Path $HaRoot  $folder
  $code = Run-Robo -src $src -dst $dst -folderName $folder
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
    Log "SKIP (missing in repo): $src" "DarkYellow"
  }
}

$max = ($exitCodes | Measure-Object -Maximum).Maximum
Log "Robocopy exit codes: $($exitCodes -join ', ')" "Cyan"
Log "Max exit code: $max" "Cyan"

# Robocopy: 0-7 = OK. >=8 = error.
if ($max -ge 8) {
  Log "SYNC FALLITA (robocopy >= 8). Guarda permessi/lock/path." "Red"
  exit $max
}

Log "SYNC OK." "Green"
exit 0
