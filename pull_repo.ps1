# pull_repo.ps1  — PS 5.1 safe (no emoji, no &&)
[CmdletBinding()]
param(
    [switch]$IgnoreLocalChanges
)

Write-Host "Controllo stato repository..."

$stashName = "watch-remote-auto-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$stashCreated = $false

if (-not $IgnoreLocalChanges) {
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
} else {
    Write-Host "IGNORA MODIFICHE: creo uno stash temporaneo prima del pull." -ForegroundColor Yellow
    $stashOutput = git stash push --include-untracked --message $stashName 2>&1
    if ($LASTEXITCODE -eq 0 -and -not ($stashOutput -match "No local changes")) {
        $stashCreated = $true
        Write-Host "Salvate modifiche locali nello stash '$stashName'." -ForegroundColor Yellow
    } else {
        Write-Host "Nessuna modifica locale da salvare." -ForegroundColor DarkGray
    }
}

# 2) pull con rebase
$pullArgs = @("pull", "--rebase", "origin", "main")
if ($IgnoreLocalChanges) {
    $pullArgs = @("pull", "--rebase", "--autostash", "origin", "main")
}

Write-Host "Eseguo: git $($pullArgs -join ' ')"
git @pullArgs
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRORE: pull fallito (probabili conflitti). Risolvi e riprova." -ForegroundColor Red
    if ($IgnoreLocalChanges -and $stashCreated) {
        Write-Host "Ripristino lo stash temporaneo..." -ForegroundColor Yellow
        git stash pop --quiet
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ATTENZIONE: ripristino stash fallito. Recupera manualmente con 'git stash pop'." -ForegroundColor Red
        }
    }
    Read-Host "Premi INVIO per chiudere..."
    exit 1
}

if ($IgnoreLocalChanges -and $stashCreated) {
    Write-Host "Ripristino lo stash temporaneo..." -ForegroundColor Yellow
    $popOutput = git stash pop 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ATTENZIONE: ripristino stash fallito. Recupera manualmente con 'git stash pop'." -ForegroundColor Red
        Write-Host $popOutput
        Read-Host "Premi INVIO per chiudere..."
        exit 1
    }
}

Write-Host "OK: repository locale aggiornato." -ForegroundColor Green
Read-Host "Premi INVIO per chiudere..."
