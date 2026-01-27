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

function Get-TrackedYamlFiles {
    param([string]$Root)
    $tracked = @()
    $output = & git -C $Root ls-files -z -- '*.yaml' '*.yml' 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error 'Unable to enumerate tracked YAML files.'
        exit 1
    }
    if ($output) {
        $tracked = $output -split "`0" | Where-Object { $_ -ne '' }
    }
    return $tracked
}

try {
    $repoRoot = Get-RepoRoot

    $utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)   # no BOM, throw on invalid
    $utf8NoBom   = New-Object System.Text.UTF8Encoding($false)         # no BOM

    $writeFailed = $false
    $fixedCount  = 0
    $okCount     = 0
    $skipCount   = 0
    $fixedFiles  = New-Object System.Collections.Generic.List[string]

    $yamlFiles = Get-TrackedYamlFiles -Root $repoRoot

    foreach ($relativePath in $yamlFiles) {
        if (-not $relativePath) { continue }
        $fullPath = Join-Path $repoRoot $relativePath

        if (-not (Test-Path -Path $fullPath -PathType Leaf)) {
            Write-Host ("[SKIP] {0} (missing)" -f $relativePath)
            $skipCount++
            continue
        }

        $needsFix = $false
        $reasons = New-Object System.Collections.Generic.List[string]

        $rawBytes = [System.IO.File]::ReadAllBytes($fullPath)
        $hasBom = ($rawBytes.Length -ge 3 -and $rawBytes[0] -eq 0xEF -and $rawBytes[1] -eq 0xBB -and $rawBytes[2] -eq 0xBF)
        if ($hasBom) { $needsFix = $true; $reasons.Add('bom') }

        [byte[]]$bytesToDecode = $rawBytes
        if ($hasBom) {
            if ($rawBytes.Length -gt 3) {
                $bytesToDecode = $rawBytes[3..($rawBytes.Length - 1)]
            } else {
                $bytesToDecode = [byte[]]@()
            }
        }

        $decoded = $null
        $invalidUtf8 = $false
        try {
            $decoded = $utf8Strict.GetString($bytesToDecode)
        } catch {
            $invalidUtf8 = $true
            $needsFix = $true
            $reasons.Add('utf8_fail')
            $decoded = [System.Text.Encoding]::GetEncoding(1252).GetString($bytesToDecode)
        }

        if ($decoded -match "`r`n") { $needsFix = $true; $reasons.Add('crlf') }
        if ($decoded -match "(?<!`r)`r") { $needsFix = $true; $reasons.Add('cr') }

        $normalized = $decoded -replace "`r`n", "`n"
        $normalized = $normalized -replace "`r", "`n"

        $builder = New-Object System.Text.StringBuilder
        $removedControl = $false
        foreach ($char in $normalized.ToCharArray()) {
            $code = [int][char]$char

            if ($code -in 9,10,13) { [void]$builder.Append($char); continue }

            if ($code -lt 32 -or $code -eq 127) { $removedControl = $true; continue }
            if ($code -ge 0x80 -and $code -le 0x9F) { $removedControl = $true; continue }

            [void]$builder.Append($char)
        }

        if ($removedControl) { $needsFix = $true; $reasons.Add('control_chars') }

        $cleanText = $builder.ToString()
        if (-not $cleanText.EndsWith("`n")) {
            $cleanText = $cleanText + "`n"
            $needsFix = $true
            $reasons.Add('eof_newline')
        }

        $normalizedBytes = $utf8NoBom.GetBytes($cleanText)
        if (-not $hasBom -and -not $invalidUtf8) {
            if ($rawBytes.Length -ne $normalizedBytes.Length) {
                $needsFix = $true
            } else {
                for ($i = 0; $i -lt $rawBytes.Length; $i++) {
                    if ($rawBytes[$i] -ne $normalizedBytes[$i]) {
                        $needsFix = $true
                        break
                    }
                }
            }
        }

        if (-not $needsFix) {
            Write-Host ("[OK]  {0}" -f $relativePath)
            $okCount++
            continue
        }

        try {
            [System.IO.File]::WriteAllBytes($fullPath, $normalizedBytes)
            $reasonText = ($reasons | Sort-Object -Unique) -join ','
            Write-Host ("[FIX] {0}  ({1})" -f $relativePath, $reasonText)
            $fixedCount++
            $fixedFiles.Add($relativePath) | Out-Null
        } catch {
            $writeFailed = $true
            Write-Host ("[FAIL] {0} write failed: {1}" -f $relativePath, $_.Exception.Message)
        }
    }

    Write-Host ""
    Write-Host ("Done. OK={0} FIXED={1} SKIPPED={2}" -f $okCount, $fixedCount, $skipCount)
    if ($fixedFiles.Count -gt 0) {
        Write-Host "Fixed files:"
        foreach ($fixed in $fixedFiles) {
            Write-Host (" - {0}" -f $fixed)
        }
    }

    if ($writeFailed) { exit 1 }
    exit 0
} catch {
    Write-Error $_
    exit 1
}
