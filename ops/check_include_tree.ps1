$ErrorActionPreference = 'Stop'

Write-Host "DEPRECATED: use ops/gate_include_tree.ps1"
$target = Join-Path $PSScriptRoot 'gate_include_tree.ps1'
& $target @args
exit $LASTEXITCODE
