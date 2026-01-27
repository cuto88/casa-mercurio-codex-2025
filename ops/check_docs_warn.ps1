$ErrorActionPreference = 'Stop'

Write-Host "DEPRECATED: use ops/gate_docs_warn.ps1"
$target = Join-Path $PSScriptRoot 'gate_docs_warn.ps1'
& $target @args
exit $LASTEXITCODE
