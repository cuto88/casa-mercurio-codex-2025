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

$utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)   # no BOM, throw on invalid
$utf8NoBom   = New-Object System.Text.UTF8Encoding($false)         # no BOM

$writeFailed = $false
$fixedCount  = 0
$okCount     = 0
$skipCount   = 0

$yamlFiles = Get-ChildItem -Path $repoRoot -Recurse -File -Include *.yaml, *.yml

foreach ($file in $yamlFiles) {
    $fullPath = $file.FullName
    $normalizedPath = $fullPath.Replace('/', '\').ToLowerInvariant()

    $skip = $false
    foreach ($fragment in $excludeFragments) {
        if ($normalizedPath.Contains($fragment)) { $skip = $true; break }
    }
    if ($skip) { $skipCount++; continue }

    $relativePath = Get-RelativePath -Path $fullPath -Root $repoRoot
    $needsFix = $false
    $reasons = New-Object System.Collections.Generic.List[string]
    $utf8Fail = $false

    try {
        $text = [System.IO.File]::ReadAllText($fullPath, $utf8Strict)
    } catch {
        $utf8Fail = $true
        $needsFix = $true
        $reasons.Add('utf8_fail')
    }

    if (-not $utf8Fail) {
        if (Contains-Utf8ControlRange -Text $text) { $needsFix = $true; $reasons.Add('control_chars') }
        if ($text -match "`r`n") { $needsFix = $true; $reasons.Add('crlf') }
    }

    $rawBytes = [System.IO.File]::ReadAllBytes($fullPath)
    $hasBom = ($rawBytes.Length -ge 3 -and $rawBytes[0] -eq 0xEF -and $rawBytes[1] -eq 0xBB -and $rawBytes[2] -eq 0xBF)
    if ($hasBom) { $needsFix = $true; $reasons.Add('bom') }

    if (-not $needsFix) {
        Write-Host ("[OK]  {0}" -f $relativePath)
        $okCount++
        continue
    }

    # bytes to decode
    [byte[]]$bytesToDecode = $rawBytes
    if ($hasBom) {
        if ($rawBytes.Length -gt 3) {
            $bytesToDecode = $rawBytes[3..($rawBytes.Length - 1)]
        } else {
            $bytesToDecode = [byte[]]@()
        }
    }

    # decode cp1252, normalize newlines, strip control chars (except \t \n \r) and 0x80-0x9F
    $decoded = [System.Text.Encoding]::GetEncoding(1252).GetString($bytesToDecode)
    $normalized = $decoded -replace "`r`n", "`n"
    $normalized = $normalized -replace "`r", "`n"

    $builder = New-Object System.Text.StringBuilder
    foreach ($char in $normalized.ToCharArray()) {
        $code = [int][char]$char

        # allow tab/newline/carriage-return (carriage-return should not remain after normalization, but safe)
        if ($code -in 9,10,13) { [void]$builder.Append($char); continue }

        # strip ASCII control chars + DEL
        if ($code -lt 32 -or $code -eq 127) { continue }

        # strip C1 controls (often appear as “smart garbage”)
        if ($code -ge 0x80 -and $code -le 0x9F) { continue }

        [void]$builder.Append($char)
    }

    $cleanText = $builder.ToString()

    try {
        [System.IO.File]::WriteAllText($fullPath, $cleanText, $utf8NoBom)
        $reasonText = ($reasons | Sort-Object -Unique) -join ','
        Write-Host ("[FIX] {0}  ({1})" -f $relativePath, $reasonText)
        $fixedCount++
    } catch {
        $writeFailed = $true
        Write-Host ("[FAIL] {0} write failed: {1}" -f $relativePath, $_.Exception.Message)
    }
}

Write-Host ""
Write-Host ("Done. OK={0} FIXED={1} SKIPPED={2}" -f $okCount, $fixedCount, $skipCount)

if ($writeFailed) { exit 1 }
exit 0
