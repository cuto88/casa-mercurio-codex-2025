param(
  [string]$Branch = "main",
  [string]$Target = "Z:\",
  [string]$BackupRoot = ".\_ha_runtime_backups",
  [switch]$IncludeTts,
  [switch]$IncludeWww,
  [switch]$RunConfigCheck,
  [switch]$RunGates
)

$ErrorActionPreference = "Stop"

function Say($m){ Write-Host $m }
function Fail($m){ throw $m }

function Assert-HaConfigTarget {
  param([string]$Path)

  if (-not (Test-Path $Path)) {
    Fail "Target path '$Path' not available."
  }

  $configPath = Join-Path $Path "configuration.yaml"
  if (-not (Test-Path $configPath)) {
    Fail "Target path '$Path' does not look like a Home Assistant config (missing configuration.yaml)."
  }

  $secretsPath = Join-Path $Path "secrets.yaml"
  if (-not (Test-Path $secretsPath)) {
    Fail "Refusing deploy: missing secrets.yaml at target ($secretsPath)."
  }

  $secretsLines = Get-Content -Path $secretsPath -ErrorAction Stop
  $hasKeyValue = $false
  foreach ($line in $secretsLines) {
    if ($line -match '^\s*[^#\s][^:]*\s*:\s*.+') {
      $hasKeyValue = $true
      break
    }
  }
  if (-not $hasKeyValue) {
    Fail "Refusing deploy: secrets.yaml sanity check failed (no key/value entries found)."
  }
}

function Read-OpsStateFile {
  param([string]$Path)

  $data = @{}
  if (-not (Test-Path $Path)) {
    return $data
  }
  foreach ($line in (Get-Content -Path $Path -ErrorAction Stop)) {
    if ($line -match '^\s*([^=]+)=(.*)$') {
      $data[$matches[1].Trim()] = $matches[2].Trim()
    }
  }
  return $data
}

function Write-OpsStateFile {
  param(
    [string]$Path,
    [string]$Head,
    [string]$Branch
  )

  $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"
  $content = @(
    "HEAD=$Head"
    "BRANCH=$Branch"
    "TIMESTAMP=$timestamp"
  )
  $utf8NoBom = New-Object System.Text.UTF8Encoding $false
  [System.IO.File]::WriteAllLines($Path, $content, $utf8NoBom)
}

Say "== Deploy SAFE =="

# --------------------------------------------------
# Repo context
# --------------------------------------------------
$repoRoot = (git rev-parse --show-toplevel)
Set-Location $repoRoot

Say "Repo   : $repoRoot"
Say "Target : $Target"
Say "Branch : $Branch"
Say "IncludeTts : $IncludeTts"
Say "IncludeWww : $IncludeWww"
Say "RunGates   : $RunGates"

# --------------------------------------------------
# 0) Refuse dirty working tree
# --------------------------------------------------
$statusLines = git status --porcelain
if ($statusLines) {
  $ignoredStatus = $statusLines | Where-Object { $_ -match '^\?\?\s+(\.ops_state/|ops/_logs/)' }
  if ($ignoredStatus) {
    Say "Ignoring untracked operational paths: .ops_state/, ops/_logs/"
  }
  $remainingStatus = $statusLines | Where-Object { $_ -notmatch '^\?\?\s+(\.ops_state/|ops/_logs/)' }
  if ($remainingStatus) {
    throw "Working tree NOT clean. Commit/stash first."
  }
}

# --------------------------------------------------
# 0a) Path stato operativo (repo)
# --------------------------------------------------
$opsStateDir = Join-Path $repoRoot ".ops_state"
$gatesFile = Join-Path $opsStateDir "gates.ok"

# --------------------------------------------------
# 0b) Preflight target path (map Z: if needed)
# --------------------------------------------------
if (!(Test-Path $Target)) {
  if ($Target -like "Z:\\*") {
    $share = if ($env:HA_SMB_SHARE) { $env:HA_SMB_SHARE } else { "\\192.168.178.84\config" }
    $user = $env:HA_SMB_USER
    $pass = $env:HA_SMB_PASS
    $drive = "Z:"

    $netUseCommand = "net use $drive $share"
    $netUseArgs = @($drive, $share)
    if ($user) {
      $netUseCommand += " /USER:$user"
      $netUseArgs += "/USER:$user"
      if ($pass) {
        $netUseCommand += " $pass"
        $netUseArgs += $pass
      }
    }

    Say "`n==> map $drive to $share"
    & net use @netUseArgs | Out-Null

    if ($LASTEXITCODE -ne 0 -or !(Test-Path $Target)) {
      throw "Target path '$Target' not available. Failed to map drive. Run: $netUseCommand"
    }
  } else {
    throw "Target path '$Target' not available."
  }
}

# --------------------------------------------------
# 0c) Preflight target sanity (secrets/config present)
# --------------------------------------------------
Assert-HaConfigTarget -Path $Target

# --------------------------------------------------
# 1) Update local branch (ff-only)
# --------------------------------------------------
Say "`n==> git fetch"
git fetch origin

Say "`n==> git ff-only to origin/$Branch"
git merge --ff-only "origin/$Branch"

# --------------------------------------------------
# 1b) Verifica gates.ok quando -RunGates non è usato
# --------------------------------------------------
$currentHead = (git rev-parse HEAD).Trim()
$currentBranch = (git rev-parse --abbrev-ref HEAD).Trim()

if (-not $RunGates) {
  $gatesData = Read-OpsStateFile -Path $gatesFile
  if (-not $gatesData.ContainsKey("HEAD") -or -not $gatesData.ContainsKey("BRANCH")) {
    Fail "Gates non eseguiti per questo HEAD. Esegui ops/gates_run.ps1 o usa -RunGates."
  }
  if ($gatesData["HEAD"] -ne $currentHead -or $gatesData["BRANCH"] -ne $currentBranch) {
    Fail "Gates non eseguiti per questo HEAD. Esegui ops/gates_run.ps1 o usa -RunGates."
  }
}

# --------------------------------------------------
# 2) Quality gates (must pass)
# --------------------------------------------------
Say "`n==> NOTA: eseguire gates_run prima del deploy (oppure usare -RunGates)"
if ($RunGates) {
  Say "`n==> gates_run (opzione esplicita -RunGates)"
  powershell -NoProfile -ExecutionPolicy Bypass -File ".\ops\gates_run.ps1"
}

# --------------------------------------------------
# 3) BACKUP target -> LOCAL backup (NO .storage)
# --------------------------------------------------
$stamp = (Get-Date -Format "yyyyMMdd_HHmmss")
$backupDir = Join-Path (Resolve-Path $BackupRoot) ("deploy_" + $stamp)
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

Say "`n==> BACKUP target to $backupDir"

$excludeFiles = @(
  "*.db","*.db-shm","*.db-wal",
  "*.log","*.log.*","*.fault",
  "ha_run.lock",".ha_run.lock",
  "secrets.yaml"
)

$excludeDirs  = @(
  ".git",
  ".storage",              # <<< CRITICAL EXCLUDE
  ".cloud",
  "backup",
  "backups",
  "media",
  "deps",
  "__pycache__",
  "_backup",
  "_ha_runtime_backups",
  "ops\_logs"
)

$optionalExcludeDirs = @()
if (-not $IncludeTts) { $optionalExcludeDirs += "tts" }
if (-not $IncludeWww) { $optionalExcludeDirs += "www" }

& robocopy $Target $backupDir /MIR /R:1 /W:1 /NFL /NDL /NP /NJH /NJS `
  /XF $excludeFiles /XD @($excludeDirs + $optionalExcludeDirs)

if ($LASTEXITCODE -ge 8) {
  throw "Backup robocopy failed (RC=$LASTEXITCODE)"
}

# --------------------------------------------------
# 4) DEPLOY repo -> TARGET (NO .storage)
# --------------------------------------------------
Say "`n==> DEPLOY repo -> target"

& robocopy $repoRoot $Target /MIR /R:1 /W:1 /NFL /NDL /NP /NJH /NJS `
  /XF $excludeFiles `
  /XD @(
    ".git",
    ".storage",            # <<< CRITICAL EXCLUDE
    ".cloud",
    "backup",
    "backups",
    "media",
    "deps",
    "__pycache__",
    "_backup_pre_git",
    "_ha_runtime_backups",
    "_backup",
    "ops\_logs"
  ) + $optionalExcludeDirs

if ($LASTEXITCODE -ge 8) {
  throw "Deploy robocopy failed (RC=$LASTEXITCODE)"
}

# --------------------------------------------------
# 5) Optional post-deploy config check (best effort)
# --------------------------------------------------
if ($RunConfigCheck) {
  Say "`n==> POST-DEPLOY: Home Assistant config check"
  if (Get-Command ha -ErrorAction SilentlyContinue) {
    & ha core check
    if ($LASTEXITCODE -ne 0) {
      throw "ha core check failed (RC=$LASTEXITCODE)"
    }
    Say "[OK] ha core check passed."
  } else {
    Say "ha CLI not found. Run on HA host: 'ha core check' or use UI -> Server Controls -> Check Configuration."
  }
}

# --------------------------------------------------
# 6) Scrive last_deploy.ok e consuma gates.ok
# --------------------------------------------------
New-Item -ItemType Directory -Force -Path $opsStateDir | Out-Null
Write-OpsStateFile -Path (Join-Path $opsStateDir "last_deploy.ok") -Head $currentHead -Branch $currentBranch
Remove-Item -Force -ErrorAction SilentlyContinue $gatesFile

Say "`n[OK] Deploy SAFE completed."
