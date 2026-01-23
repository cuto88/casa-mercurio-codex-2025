[CmdletBinding()]
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

$legacyTemplatePath = 'mirai/20_templates.yaml'
if (Test-Path -Path $legacyTemplatePath) {
  Write-Host "Legacy found: $legacyTemplatePath (checking)"
  $templateRoot = Get-FirstNonEmptyLine $legacyTemplatePath
  if ($templateRoot -match '^template\s*:') {
    Write-Warning "Invalid template root in mirai/20_templates.yaml: file must be a list without 'template:'."
  }
} else {
  Write-Verbose "Skipping legacy $legacyTemplatePath (not found)"
}

$legacyAutomationPath = 'mirai/30_automations.yaml'
if (Test-Path -Path $legacyAutomationPath) {
  Write-Host "Legacy found: $legacyAutomationPath (checking)"
  $automationRoot = Get-FirstNonEmptyLine $legacyAutomationPath
  if ($automationRoot -and ($automationRoot -notmatch '^-')) {
    Write-Warning "Invalid automation root in mirai/30_automations.yaml: file must start with a list item '-'."
  }
} else {
  Write-Verbose "Skipping legacy $legacyAutomationPath (not found)"
}

$fail = $false

if ($CheckEntityMap) {
  $scriptRoot = Split-Path -Parent $PSCommandPath
  & (Join-Path $scriptRoot 'check_entity_map.ps1') -Mode strict_clima
  $entityExit = $LASTEXITCODE
  if ($entityExit -ne 0) {
    $fail = $true
    Write-Error ("Entity map gate failed with exit code {0}" -f $entityExit)
  }
}
# Ensure legacy/optional checks do not fail the gate
if (-not $CheckEntityMap) {
  $fail = $false
}

if ($fail) {
  exit 1
} else {
  Write-Host 'MIRAI package structure check passed.'
  exit 0
}
