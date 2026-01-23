$ErrorActionPreference = 'Stop'

function Get-RepoRoot {
    $root = (& git rev-parse --show-toplevel 2>$null)
    if (-not $root) {
        Write-Error 'Unable to resolve git repo root.'
        exit 1
    }
    return $root.Trim()
}

function Get-RelativePath {
    param(
        [string]$Path,
        [string]$Root
    )
    if ($Path.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $Path.Substring($Root.Length).TrimStart('\', '/')
    }
    return $Path
}

function Contains-Utf8ControlRange {
    param([string]$Text)
    foreach ($char in $Text.ToCharArray()) {
        $code = [int][char]$char
        if ($code -ge 0x80 -and $code -le 0x9F) {
            return $true
        }
    }
    return $false
}

$repoRoot = Get-RepoRoot
$excludeFragments = @(
    '\.git\',
    '\_quarantine\',
    '\_backup_pre_git\',
    '\_ha_runtime_backups\',
    '\deps\',
    '\www\',
    '\tts\'
) | ForEach-Object { $_.ToLowerInvariant() }

$utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false, $false)
$writeFailed = $false

$yamlFiles = Get-ChildItem -Path $repoRoot -Recurse -File -Include *.yaml, *.yml

foreach ($file in $yamlFiles) {
    $fullPath = $file.FullName
    $normalizedPath = $fullPath.Replace('/', '\').ToLowerInvariant()
    $skip = $false
    foreach ($fragment in $excludeFragments) {
        if ($normalizedPath.Contains($fragment)) {
            $skip = $true
            break
        }
    }
    if ($skip) {
        continue
    }

    $relativePath = Get-RelativePath -Path $fullPath -Root $repoRoot
    $needsFix = $false
    $reasons = New-Object System.Collections.Generic.List[string]
    $rawBytes = $null
    $utf8Fail = $false

    try {
        $text = [System.IO.File]::ReadAllText($fullPath, $utf8Strict)
    } catch {
        $utf8Fail = $true
        $needsFix = $true
        $reasons.Add('utf8_fail')
    }

    if (-not $utf8Fail) {
        if (Contains-Utf8ControlRange -Text $text) {
            $needsFix = $true
            $reasons.Add('control_chars')
        }
        if ($text -match "`r`n") {
            $needsFix = $true
            $reasons.Add('crlf')
        }
    }

    $rawBytes = [System.IO.File]::ReadAllBytes($fullPath)
    $hasBom = $rawBytes.Length -ge 3 -and $rawBytes[0] -eq 0xEF -and $rawBytes[1] -eq 0xBB -and $rawBytes[2] -eq 0xBF
    if ($hasBom) {
        $needsFix = $true
        $reasons.Add('bom')
    }

    if (-not $needsFix) {
        Write-Host ("[OK] {0} unchanged" -f $relativePath)
        continue
    }

    if ($hasBom) {
        if ($rawBytes.Length -gt 3) {
            $bytesToDecode = $rawBytes[3..($rawBytes.Length - 1)]
        } else {
            $bytesToDecode = @()
        }
    } else {
        $bytesToDecode = $rawBytes
    }

    $decoded = [System.Text.Encoding]::GetEncoding(1252).GetString($bytesToDecode)
    $normalized = $decoded -replace "`r`n", "`n"
    $normalized = $normalized -replace "`r", "`n"

    $builder = New-Object System.Text.StringBuilder
    foreach ($char in $normalized.ToCharArray()) {
        $code = [int][char]$char
        if ($code -eq 9 -or $code -eq 10 -or $code -eq 13) {
            $null = $builder.Append($char)
            continue
        }
        if ($code -lt 32 -or $code -eq 127) {
            continue
        }
        if ($code -ge 0x80 -and $code -le 0x9F) {
            continue
        }
        $null = $builder.Append($char)
    }

    $cleanText = $builder.ToString()
    try {
        [System.IO.File]::WriteAllText($fullPath, $cleanText, $utf8NoBom)
        $reasonText = ($reasons | Sort-Object -Unique) -join ','
        Write-Host ("[FIX] {0} rewritten (reason: {1})" -f $relativePath, $reasonText)
    } catch {
        $writeFailed = $true
        Write-Host ("[FAIL] {0} write failed: {1}" -f $relativePath, $_.Exception.Message)
    }
}

if ($writeFailed) {
    exit 1
}
