$ErrorActionPreference = 'Stop'

param(
  [string]$ConfigPath
)

$RepoRoot = Split-Path -Path $PSScriptRoot -Parent
$configFile = if ($ConfigPath) { $ConfigPath } else { Join-Path $RepoRoot 'configuration.yaml' }

if (-not (Test-Path -Path $configFile)) {
  Write-Error "configuration.yaml not found at path: $configFile"
  exit 1
}

$missing = @()
$dashboards = @()

foreach ($line in Get-Content -Path $configFile) {
  $trimmed = $line.Trim()
  if (-not $trimmed -or $trimmed.StartsWith('#')) {
    continue
  }

  if ($trimmed -match '^\s*filename:\s*(\S+)\s*$') {
    $path = $Matches[1]
    $dashboards += $path
    $fullPath = if ([System.IO.Path]::IsPathRooted($path)) {
      $path
    } else {
      Join-Path $RepoRoot $path
    }

    if (-not (Test-Path -Path $fullPath)) {
      $missing += $path
    }
  }
}

if (-not $dashboards) {
  Write-Error 'No Lovelace dashboards found in configuration.yaml (filename: entries missing).'
  exit 1
}

if ($missing.Count -gt 0) {
  Write-Error ("Missing Lovelace dashboard files: {0}" -f ($missing -join ', '))
  exit 1
}

Write-Host ("Include tree check passed ({0} dashboards found)." -f $dashboards.Count)
