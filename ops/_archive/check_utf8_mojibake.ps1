$ErrorActionPreference = 'Stop'

function Get-RepoRoot {
    $root = (& git rev-parse --show-toplevel 2>$null)
    if (-not $root) {
        Write-Error 'Unable to resolve git repo root.'
        exit 1
    }
    return $root.Trim()
}

function Get-TrackedFiles {
    param(
        [string]$Root,
        [string[]]$Patterns
    )

    $tracked = @()
    $output = & git -C $Root ls-files -z -- $Patterns 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error 'Unable to enumerate tracked files.'
        exit 1
    }

    if ($output) {
        $tracked = $output -split "`0" | Where-Object { $_ -ne '' }
    }

    return $tracked
}

$repoRoot = Get-RepoRoot
$patterns = @('*.yaml', '*.yml', '*.md', '*.json', '*.js', '*.ts', '*.css')
$regex = 'Ã|Â|�|â€™|â€“|â€œ|â€|Â°|Â³'

$files = Get-TrackedFiles -Root $repoRoot -Patterns $patterns

$matches = @()
foreach ($relativePath in $files) {
    if (-not $relativePath) { continue }

    $fullPath = Join-Path $repoRoot $relativePath
    if (-not (Test-Path -Path $fullPath -PathType Leaf)) { continue }

    $found = Select-String -Path $fullPath -Pattern $regex
    if ($found) {
        $matches += $found
    }
}

if ($matches.Count -gt 0) {
    foreach ($match in $matches) {
        Write-Host ("{0}:{1}:{2}" -f $match.Path, $match.LineNumber, $match.Line.Trim())
    }
    exit 1
}

Write-Host "OK: no mojibake patterns"
exit 0
