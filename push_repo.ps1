param(
    [string]$Message = "Update from push_repo.ps1"
)

$ErrorActionPreference = "Stop"

Write-Host "=== push_repo.ps1 ==="
Write-Host "Messaggio commit: $Message"
Write-Host ""

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "ERRORE: git non trovato nel PATH." -ForegroundColor Red
    exit 1
}

# Controlla se ci sono modifiche
$status = git status --porcelain
if (-not $status) {
    Write-Host "Nessuna modifica da committare/pushare."
    exit 0
}

Write-Host "Aggiungo tutti i file (git add -A)..."
git add -A
if ($LASTEXITCODE -ne 0) {
    Write-Host "git add fallito." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Eseguo commit..."
git commit -m "$Message"
if ($LASTEXITCODE -ne 0) {
    Write-Host "git commit fallito." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Eseguo push su origin HEAD..."
git push origin HEAD
if ($LASTEXITCODE -ne 0) {
    Write-Host "git push fallito." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Push completato con successo."
exit 0
