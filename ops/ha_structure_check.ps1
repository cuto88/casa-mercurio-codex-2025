$ErrorActionPreference = 'Stop'

Write-Host "DEPRECATED: use ops/gate_ha_structure.ps1"
$target = Join-Path $PSScriptRoot 'gate_ha_structure.ps1'
& $target @args
exit $LASTEXITCODE
