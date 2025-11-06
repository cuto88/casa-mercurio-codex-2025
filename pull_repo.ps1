# === pull_repo.ps1 ===
Write-Host "🔍 Controllo stato repository..." -ForegroundColor Cyan

# Ignora untracked; blocca se ci sono modifiche effettive non committate
git diff --quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Modifiche locali non committate (worktree). Fai: git add . && git commit -m \"msg\"" -ForegroundColor Yellow
    exit 1
}
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Modifiche in stage. Fai: git commit -m \"msg\"" -ForegroundColor Yellow
    exit 1
}

Write-Host "⬇️  Pull --rebase da origin/main..." -ForegroundColor Cyan
git pull --rebase origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Repo locale aggiornato." -ForegroundColor Green
} else {
    Write-Host "❌ Pull fallito (conflitti?). Risolvi e riprova." -ForegroundColor Red
    exit 1
}
