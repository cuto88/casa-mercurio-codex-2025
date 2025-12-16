param(
    [switch]$IgnoreLocalChanges
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Path $PSScriptRoot -Parent
Push-Location $RepoRoot

function Write-Log {
    param(
        [string]$Message,
        [System.ConsoleColor]$Color = [System.ConsoleColor]::White
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

try {
    Write-Log "=== pull_repo.ps1 ==="
    Write-Log "IgnoreLocalChanges = $IgnoreLocalChanges"
    Write-Host ""

    # Verifica presenza git
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Log "ERRORE: git non trovato nel PATH." Red
        exit 1
    }

    # Determina il branch corrente
    $branch = (git rev-parse --abbrev-ref HEAD).Trim()
    if (-not $branch) { $branch = "main" }

    Write-Log "Branch corrente: $branch"
    Write-Host ""

    if ($IgnoreLocalChanges) {
        Write-Log "Modalità FORZATA: ignoro modifiche locali." Yellow

        git fetch origin $branch
        if ($LASTEXITCODE -ne 0) {
            Write-Log "git fetch fallito." Red
            exit $LASTEXITCODE
        }

        Write-Log "Reset hard su origin/$branch ..." Cyan
        git reset --hard origin/$branch
        if ($LASTEXITCODE -ne 0) {
            Write-Log "git reset --hard fallito." Red
            exit $LASTEXITCODE
        }

        Write-Log "Pulizia file non tracciati (git clean -fd) ..." Cyan
        git clean -fd
        if ($LASTEXITCODE -ne 0) {
            Write-Log "git clean fallito." Red
            exit $LASTEXITCODE
        }

    } else {
        Write-Log "Modalità SAFE: verifico modifiche locali." Cyan

        $status = git status --porcelain
        if ($status) {
            Write-Log "Ci sono modifiche locali non committate. Commit/stash prima del pull." Yellow
            exit 1
        }

        git fetch origin $branch
        if ($LASTEXITCODE -ne 0) {
            Write-Log "git fetch fallito." Red
            exit $LASTEXITCODE
        }

        Write-Log "Eseguo git pull --ff-only origin $branch ..." Cyan
        git pull --ff-only origin $branch
        if ($LASTEXITCODE -ne 0) {
            Write-Log "git pull fallito." Red
            exit $LASTEXITCODE
        }
    }

    Write-Host ""
    Write-Log "Pull completato con successo." Green
    exit 0
}
finally {
    Pop-Location
}
