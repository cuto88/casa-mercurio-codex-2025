$ErrorActionPreference = 'Stop'

Write-Host "DEPRECATED: use ops/gates_run.ps1"
$target = Join-Path $PSScriptRoot 'gates_run.ps1'
& $target @args
exit $LASTEXITCODE
