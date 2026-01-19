param(
  [switch]$CheckEntityMap
)

$ErrorActionPreference = 'Stop'

function Get-FirstNonEmptyLine([string] $path) {
  foreach ($line in Get-Content -Path $path) {
    $trimmed = $line.Trim()
    if ($trimmed -and -not $trimmed.StartsWith('#')) {
      return $trimmed
    }
  }
  return $null
}

$fail = $false

$legacyMiraiPath = 'packages/mirai.yaml'
if (Test-Path -Path $legacyMiraiPath) {
  Write-Warning 'legacy mirai.yaml present'
}

$miraiSplitFiles = @(
  'packages/mirai_core.yaml',
  'packages/mirai_modbus.yaml',
  'packages/mirai_templates.yaml'
)
$missingMiraiFiles = @()
foreach ($miraiFile in $miraiSplitFiles) {
  if (-not (Test-Path -Path $miraiFile)) {
    Write-Warning ("Missing {0}" -f $miraiFile)
    $missingMiraiFiles += $miraiFile
  }
}
if ($missingMiraiFiles.Count -eq 0) {
  Write-Host 'Mirai split files present: OK'
}

$templateRoot = Get-FirstNonEmptyLine 'mirai/20_templates.yaml'
if ($templateRoot -match '^template\s*:') {
  Write-Error "Invalid template root in mirai/20_templates.yaml: file must be a list without 'template:'."
  $fail = $true
}

$automationRoot = Get-FirstNonEmptyLine 'mirai/30_automations.yaml'
if ($automationRoot -and ($automationRoot -notmatch '^-')) {
  Write-Error "Invalid automation root in mirai/30_automations.yaml: file must start with a list item '-'."
  $fail = $true
}

if ($CheckEntityMap) {
  $scriptRoot = Split-Path -Parent $PSCommandPath
  & (Join-Path $scriptRoot 'check_entity_map.ps1') -Mode strict_clima
  if ($LASTEXITCODE -ne 0) {
    $fail = $true
  }
}

if ($fail) {
  exit 1
}

Write-Host 'MIRAI package structure check passed.'
