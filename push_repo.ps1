# push_repo.ps1  — PS 5.1 safe (no emoji, no &&)
Write-Host "Preparazione push verso origin/main..."

# 1) Mostra stato sintetico
Write-Host ""
Write-Host "Stato repository (git status -sb):" -ForegroundColor Cyan
git status -sb
Write-Host ""

# 2) Chiedi se aggiungere automaticamente tutte le modifiche
$answer = Read-Host "Aggiungere TUTTE le modifiche con 'git add .'? [s/N]"
if ($answer -eq "s" -or $answer -eq "S") {
    Write-Host "Eseguo: git add ."
    git add .
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERRORE: git add . fallito." -ForegroundColor Red
        Read-Host "Premi INVIO per chiudere..."
        exit 1
    }
} else {
    Write-Host "OK: salto 'git add .'. Seleziona tu i file prima di continuare."
}

# 3) Verifica se ci sono differenze da committare
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
    # Ci sono file in stage → chiedi messaggio commit
    $commitMsg = Read-Host "Inserisci il messaggio di commit (default: update)"
    if ([string]::IsNullOrWhiteSpace($commitMsg)) {
        $commitMsg = "update"
    }

    Write-Host "Eseguo: git commit -m `"$commitMsg`""
    git commit -m "$commitMsg"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERRORE: commit fallito." -ForegroundColor Red
        Read-Host "Premi INVIO per chiudere..."
        exit 1
    }
} else {
    Write-Host "Nessun file in stage da committare (index pulito)." -ForegroundColor Yellow
}

# 4) Controlla se ci sono commit locali da pushare
Write-Host ""
Write-Host "Controllo se ci sono commit locali da inviare a origin/main..."
git log origin/main..HEAD --oneline > $env:TEMP\_git_to_push.txt
$toPush = Get-Content $env:TEMP\_git_to_push.txt | Where-Object { $_ -ne "" }

if (-not $toPush) {
    Write-Host "Nessun commit locale da pushare. Nulla da fare." -ForegroundColor Yellow
    Remove-Item $env:TEMP\_git_to_push.txt -ErrorAction SilentlyContinue
    Read-Host "Premi INVIO per chiudere..."
    exit 0
}

Write-Host "Commit da pushare:"
$toPush | ForEach-Object { Write-Host "  $_" }
Remove-Item $env:TEMP\_git_to_push.txt -ErrorAction SilentlyContinue

# 5) Esegui il push
Write-Host ""
Write-Host "Eseguo: git push origin main"
git push origin main
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRORE: push fallito. Controlla messaggi di git." -ForegroundColor Red
    Read-Host "Premi INVIO per chiudere..."
    exit 1
}

Write-Host "OK: push completato su origin/main." -ForegroundColor Green
Read-Host "Premi INVIO per chiudere..."
