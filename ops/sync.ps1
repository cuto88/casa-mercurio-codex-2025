$ErrorActionPreference = 'Stop'

Write-Host "DEPRECATED: use ops/repo_sync.ps1"
$target = Join-Path $PSScriptRoot 'repo_sync.ps1'
& $target @args
exit $LASTEXITCODE
