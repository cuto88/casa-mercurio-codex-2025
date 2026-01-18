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

$packageRoot = Get-FirstNonEmptyLine 'packages/mirai.yaml'
if ($packageRoot -eq 'mirai:') {
  Write-Error "Invalid wrapper key in packages/mirai.yaml: remove the 'mirai:' root."
  $fail = $true
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
