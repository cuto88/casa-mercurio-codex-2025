$ErrorActionPreference = 'Stop'

function Invoke-Git {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Args
    )

    $output = git @Args 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "git failed: git $($Args -join ' ')"
    }

    return $output
}

try {
    $repoRoot = (Invoke-Git rev-parse --show-toplevel).Trim()
} catch {
    Write-Host "STOP: not inside a git repository."
    exit 1
}

Set-Location $repoRoot

try {
    Invoke-Git fetch origin | Out-Null
    Invoke-Git reset --hard origin/main | Out-Null
    Invoke-Git clean -fd | Out-Null
} catch {
    Write-Host "STOP: git command failed. $_"
    exit 1
}

Write-Host "OK: hard-synced to origin/main"
exit 0
