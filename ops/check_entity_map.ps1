$ErrorActionPreference = 'Stop'

Write-Host "DEPRECATED: use ops/gate_entity_map.ps1"
$target = Join-Path $PSScriptRoot 'gate_entity_map.ps1'
& $target @args
exit $LASTEXITCODE
