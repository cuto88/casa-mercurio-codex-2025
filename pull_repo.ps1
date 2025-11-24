param(
    [switch]$IgnoreLocalChanges
)

$ErrorActionPreference = "Stop"

Write-Host "=== pull_repo.ps1 ==="
Write-Host "IgnoreLocalChanges = $IgnoreLocalChanges"
Write-Host ""

# Verifica presenza git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "ERRORE: git non trovato nel PATH." -ForegroundColor Red
    exit 1
}

# Determina il branch corrente
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
if (-not $branch) { $branch = "main" }

Write-Host "Branch corrente: $branch"
Write-Host ""

if ($IgnoreLocalChanges) {
    Write-Host "Modalità FORZATA: ignoro modifiche locali." -ForegroundColor Yellow

    git fetch origin $branch
    if ($LASTEXITCODE -ne 0) {
        Write-Host "git fetch fallito." -ForegroundColor Red
        exit $LASTEXITCODE
    }

    Write-Host "Reset hard su origin/$branch ..."
    git reset --hard origin/$branch
    if ($LASTEXITCODE -ne 0) {
        Write-Host "git reset --hard fallito." -ForegroundColor Red
        exit $LASTEXITCODE
    }

    Write-Host "Pulizia file non tracciati (git clean -fd) ..."
    git clean -fd
    if ($LASTEXITCODE -ne 0) {
        Write-Host "git clean fallito." -ForegroundColor Red
        exit $LASTEXITCODE
    }

} else {
    Write-Host "Modalità SAFE: verifico modifiche locali."

    $status = git status --porcelain
    if ($status) {
        Write-Host "Ci sono modifiche locali non committate. Commit/stash prima del pull." -ForegroundColor Yellow
        exit 1
    }

    git fetch origin $branch
    if ($LASTEXITCODE -ne 0) {
        Write-Host "git fetch fallito." -ForegroundColor Red
        exit $LASTEXITCODE
    }

    Write-Host "Eseguo git pull --ff-only origin $branch ..."
    git pull --ff-only origin $branch
    if ($LASTEXITCODE -ne 0) {
        Write-Host "git pull fallito." -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

Write-Host ""
Write-Host "Pull completato con successo."
exit 0
