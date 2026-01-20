param(
  [string]$Branch = "main",
  [string]$Target = "Z:\",
  [string]$BackupRoot = ".\_ha_runtime_backups"
)

$ErrorActionPreference = "Stop"

function Say($m){ Write-Host $m }

Say "== Deploy SAFE =="
$repoRoot = (git rev-parse --show-toplevel)
Set-Location $repoRoot
Say "Repo   : $repoRoot"
Say "Target : $Target"
Say "Branch : $Branch"

# 0) Refuse dirty working tree
if (git status --porcelain) {
  throw "Working tree NOT clean. Commit/stash first."
}

# 1) Update local branch (ff-only)
Say "`n==> git fetch"
git fetch origin

Say "`n==> git ff-only to origin/$Branch"
git merge --ff-only "origin/$Branch"

# 2) Gates (must pass)
Say "`n==> run_gates"
powershell -NoProfile -ExecutionPolicy Bypass -File ".\ops\run_gates.ps1"

# 3) Backup TARGET -> local backups
$stamp = (Get-Date -Format "yyyyMMdd_HHmmss")
$backupDir = Join-Path (Resolve-Path $BackupRoot) ("deploy_" + $stamp)
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

Say "`n==> BACKUP target to $backupDir"
$excludeFiles = @("*.db","*.db-shm","*.db-wal","*.log","*.log.*","*.fault",".ha_run.lock","ha_run.lock")
$excludeDirs  = @(".git","deps","__pycache__","_backup","_ha_runtime_backups","ops\_logs")

& robocopy $Target $backupDir /MIR /R:1 /W:1 /NFL /NDL /NP /NJH /NJS `
  /XF $excludeFiles /XD $excludeDirs
if ($LASTEXITCODE -ge 8) { throw "Backup robocopy failed (RC=$LASTEXITCODE)" }

# 4) Deploy repo -> TARGET
Say "`n==> DEPLOY repo -> target"
& robocopy $repoRoot $Target /MIR /R:1 /W:1 /NFL /NDL /NP /NJH /NJS `
  /XF $excludeFiles /XD @(".git","deps","__pycache__","_backup_pre_git","_ha_runtime_backups","_backup","ops\_logs")
if ($LASTEXITCODE -ge 8) { throw "Deploy robocopy failed (RC=$LASTEXITCODE)" }

Say "`n[OK] Deploy SAFE completed."
