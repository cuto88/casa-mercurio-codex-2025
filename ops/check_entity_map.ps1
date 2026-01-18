param(
  [string]$EntityMapPath = 'logica/core/README_sensori_clima.md',
  [string]$PackagesPath = 'packages',
  [string]$LovelacePath = 'lovelace',
  [ValidateSet('strict_clima', 'report_only')]
  [string]$Mode = 'strict_clima',
  [string[]]$ClimaPrefixes = @(
    'temperatura_',
    'umidita_',
    'vmc_',
    'ac_',
    'heating_',
    'dewpoint_'
  )
)

$ErrorActionPreference = 'Stop'

$pattern = '\b(sensor|binary_sensor|switch|climate|input_boolean|input_number|number|select|button|fan|cover|light)\.[a-z0-9_]+' + '\b'

function Get-EntityIdsFromText {
  param([string]$Text)
  if (-not $Text) {
    return @()
  }
  $matches = [regex]::Matches($Text, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
  return $matches | ForEach-Object { $_.Value.ToLowerInvariant() }
}

function New-HashSet {
  return [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
}

function Get-BaseName {
  param([string]$EntityId)
  $parts = $EntityId.Split('.', 2)
  if ($parts.Count -lt 2) {
    return ''
  }
  return $parts[1]
}

function Is-ClimaCandidate {
  param(
    [string]$EntityId,
    [System.Collections.Generic.HashSet[string]]$MapSet,
    [string[]]$Prefixes
  )
  if ($MapSet.Contains($EntityId)) {
    return $true
  }
  $baseName = (Get-BaseName -EntityId $EntityId).ToLowerInvariant()
  foreach ($prefix in $Prefixes) {
    if ($baseName.StartsWith($prefix.ToLowerInvariant())) {
      return $true
    }
  }
  return $false
}

if (-not (Test-Path -Path $EntityMapPath)) {
  Write-Error "Entity map not found: $EntityMapPath"
  exit 1
}

$mapText = Get-Content -Path $EntityMapPath -Raw
$mapEntities = Get-EntityIdsFromText -Text $mapText | Sort-Object -Unique
$mapSet = New-HashSet
$mapEntities | ForEach-Object { [void]$mapSet.Add($_) }

$files = @()
if (Test-Path -Path $PackagesPath) {
  $files += Get-ChildItem -Path $PackagesPath -Recurse -File -Include *.yaml, *.yml
} else {
  Write-Warning "Packages path not found: $PackagesPath"
}

if (Test-Path -Path $LovelacePath) {
  $files += Get-ChildItem -Path $LovelacePath -Recurse -File -Include *.yaml, *.yml
} else {
  Write-Warning "Lovelace path not found: $LovelacePath"
}

$usedEntities = New-HashSet
$entityUsage = @{}

foreach ($file in $files) {
  $content = Get-Content -Path $file.FullName -Raw
  $found = Get-EntityIdsFromText -Text $content
  foreach ($entityId in $found) {
    [void]$usedEntities.Add($entityId)
    if (-not $entityUsage.ContainsKey($entityId)) {
      $entityUsage[$entityId] = [System.Collections.Generic.HashSet[string]]::new()
    }
    [void]$entityUsage[$entityId].Add($file.FullName)
  }
}

$usedList = $usedEntities | Sort-Object
$usedClima = $usedList | Where-Object { Is-ClimaCandidate -EntityId $_ -MapSet $mapSet -Prefixes $ClimaPrefixes }
$usedNonClima = $usedList | Where-Object { -not (Is-ClimaCandidate -EntityId $_ -MapSet $mapSet -Prefixes $ClimaPrefixes) }

$missingInMap = $usedClima | Where-Object { -not $mapSet.Contains($_) }
$inMapNotUsed = $mapEntities | Where-Object { -not $usedEntities.Contains($_) }

Write-Host "Entity map count: $($mapEntities.Count)"
Write-Host "Used entity count: $($usedEntities.Count)"
Write-Host "Used clima candidates: $($usedClima.Count)"
Write-Host "Used non-clima entities: $($usedNonClima.Count)"
Write-Host "Missing in map (clima only): $($missingInMap.Count)"
Write-Host "In map but not used: $($inMapNotUsed.Count)"

if ($missingInMap.Count -gt 0) {
  Write-Host '--- Missing in map (showing up to 50) ---'
  $missingInMap | Sort-Object | Select-Object -First 50 | ForEach-Object {
    $entityId = $_
    $exampleFile = $null
    if ($entityUsage.ContainsKey($entityId)) {
      $exampleFile = $entityUsage[$entityId] | Select-Object -First 1
    }
    if ($exampleFile) {
      Write-Host "- $entityId (e.g. $exampleFile)"
    } else {
      Write-Host "- $entityId"
    }
  }
}

$normalizedGroups = @{}
foreach ($entityId in $usedClima) {
  $baseName = Get-BaseName -EntityId $entityId
  if (-not $baseName) {
    continue
  }
  $normalized = $baseName.ToLowerInvariant().Replace('_', '')
  if (-not $normalizedGroups.ContainsKey($normalized)) {
    $normalizedGroups[$normalized] = @()
  }
  $normalizedGroups[$normalized] += $entityId
}

$duplicateCandidates = @()
foreach ($group in $normalizedGroups.GetEnumerator()) {
  $uniqueEntities = $group.Value | Sort-Object -Unique
  if ($uniqueEntities.Count -gt 1) {
    $duplicateCandidates += [PSCustomObject]@{
      Name = $group.Key
      Entities = $uniqueEntities
    }
  }
}
if ($duplicateCandidates.Count -gt 0) {
  Write-Warning 'Possible duplicate/alias clima entities (normalized name collisions):'
  foreach ($group in $duplicateCandidates) {
    Write-Warning "- $($group.Entities -join ', ')"
  }
}

$renameGroups = @{}
foreach ($entityId in $usedClima) {
  $parts = $entityId.Split('.', 2)
  if ($parts.Count -lt 2) {
    continue
  }
  $domain = $parts[0]
  $baseName = $parts[1].ToLowerInvariant()
  if (-not $renameGroups.ContainsKey($baseName)) {
    $renameGroups[$baseName] = @{}
  }
  if (-not $renameGroups[$baseName].ContainsKey($domain)) {
    $renameGroups[$baseName][$domain] = @()
  }
  $renameGroups[$baseName][$domain] += $entityId
}

$renamedCandidates = $renameGroups.GetEnumerator() | Where-Object { $_.Value.Keys.Count -gt 1 }
if ($renamedCandidates.Count -gt 0) {
  Write-Warning 'Possible renamed clima entities (same base name across domains):'
  foreach ($group in $renamedCandidates) {
    $domains = $group.Value.Keys | Sort-Object
    $entities = @()
    foreach ($domain in $domains) {
      $entities += $group.Value[$domain]
    }
    $entities = $entities | Sort-Object -Unique
    Write-Warning "- $($entities -join ', ')"
  }
}

if ($Mode -eq 'strict_clima' -and $missingInMap.Count -gt 0) {
  exit 1
}

Write-Host 'Entity map check completed.'
