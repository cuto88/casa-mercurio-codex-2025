$ErrorActionPreference = 'Stop'

Write-Host "DEPRECATED: use ops/hygiene_fix_yaml_encoding.ps1"
$target = Join-Path $PSScriptRoot 'hygiene_fix_yaml_encoding.ps1'
& $target @args
exit $LASTEXITCODE
