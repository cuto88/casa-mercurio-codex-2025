param(
  [switch]$RunDeploy,
  [switch]$RunRestart,
  [string]$HaHost = "root@192.168.178.84",
  [int]$Port = 2222,
  [string]$KeyPath = "C:\Users\randalab\.ssh\ha_ed25519"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot

function Say([string]$msg) {
  Write-Host $msg
}

$pwshExe = "C:\Program Files\PowerShell\7\pwsh.exe"
$sshExe = "C:\Windows\System32\OpenSSH\ssh.exe"

if ($RunDeploy) {
  Say "==> Deploy SAFE"
  & powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "deploy_safe.ps1")
  if ($LASTEXITCODE -ne 0) {
    throw "deploy_safe failed (RC=$LASTEXITCODE)"
  }
}

Say "==> HA core check"
$checkCmd = "& '$sshExe' -p $Port -i '$KeyPath' $HaHost 'ha core check'"
& $pwshExe -Command $checkCmd
if ($LASTEXITCODE -ne 0) {
  throw "ha core check failed (RC=$LASTEXITCODE)"
}

if ($RunRestart) {
  Say "==> HA core restart + check"
  $restartCmd = "& '$sshExe' -p $Port -i '$KeyPath' $HaHost 'ha core restart && ha core check'"
  & $pwshExe -Command $restartCmd
  if ($LASTEXITCODE -ne 0) {
    throw "ha core restart/check failed (RC=$LASTEXITCODE)"
  }
}

Say "==> Phase1 runtime truth check"
& powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "phase1_runtime_truth_check.ps1") `
  -HaHost $HaHost -Port $Port -KeyPath $KeyPath
if ($LASTEXITCODE -ne 0) {
  throw "phase1_runtime_truth_check failed (RC=$LASTEXITCODE)"
}

$dateDir = Join-Path $repoRoot ("docs\runtime_evidence\" + (Get-Date -Format "yyyy-MM-dd"))
$currentBootScan = Get-ChildItem $dateDir -Filter "phase1_runtime_truth_scan_current_boot_*.txt" |
  Sort-Object LastWriteTime -Descending | Select-Object -First 1
$writerScan = Get-ChildItem $dateDir -Filter "phase1_runtime_truth_writer_scan_*.txt" |
  Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($null -eq $currentBootScan -or $null -eq $writerScan) {
  throw "runtime truth output files not found in $dateDir"
}

Say "==> Summary"
Say ("Current boot scan : " + $currentBootScan.FullName)
Get-Content $currentBootScan.FullName | ForEach-Object { Say ("  " + $_) }
Say ("Writer scan       : " + $writerScan.FullName)
Get-Content $writerScan.FullName | ForEach-Object { Say ("  " + $_) }

Say "Phase2 post-deploy verification completed."
