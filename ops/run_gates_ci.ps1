$ErrorActionPreference = 'Stop'

Write-Host "DEPRECATED: use ops/gates_run_ci.ps1"
$target = Join-Path $PSScriptRoot 'gates_run_ci.ps1'
& $target @args
exit $LASTEXITCODE
