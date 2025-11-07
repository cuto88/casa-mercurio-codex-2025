# pull_repo.ps1  — PS 5.1 safe (no emoji, no &&)
Write-Host "Controllo stato repository..."

# 1) blocca se ci sono modifiche locali non committate (ignora gli untracked)
git diff --quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "ATTENZIONE: modifiche locali non committate (worktree)." -ForegroundColor Yellow
    Write-Host 'Esegui:  git add .  ;  git commit -m "msg"' -ForegroundColor Yellow
    exit 1
}
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "ATTENZIONE: ci sono file in stage (index)." -ForegroundColor Yellow
    Write-Host 'Esegui:  git commit -m "msg"' -ForegroundColor Yellow
    exit 1
}

# 2) pull con rebase
Write-Host "Eseguo: git pull --rebase origin main"
git pull --rebase origin main
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRORE: pull fallito (probabili conflitti). Risolvi e riprova." -ForegroundColor Red
    Read-Host "Premi INVIO per chiudere..."
    exit 1
}

Write-Host "OK: repository locale aggiornato." -ForegroundColor Green
Read-Host "Premi INVIO per chiudere..."
