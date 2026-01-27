$ErrorActionPreference = 'Stop'

Write-Host "DEPRECATED: use ops/gate_vmc_dashboards.ps1"
$target = Join-Path $PSScriptRoot 'gate_vmc_dashboards.ps1'
& $target @args
exit $LASTEXITCODE
