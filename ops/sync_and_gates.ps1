$ErrorActionPreference = 'Stop'

Write-Host "DEPRECATED: use ops/repo_sync_and_gates.ps1"
$target = Join-Path $PSScriptRoot 'repo_sync_and_gates.ps1'
& $target @args
exit $LASTEXITCODE
