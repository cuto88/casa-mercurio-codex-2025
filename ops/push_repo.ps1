# ops\push_repo.ps1
# Safe commit + push (PS 5.1). No surprises.

[CmdletBinding()]
param(
    [string]$Message = "Update from push_repo.ps1",
    [switch]$All      # se presente, fa git add -A (default: add solo tracked + nuovi sotto repo, ma con preview)
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Path $PSScriptRoot -Parent
Push-Location $RepoRoot

function TS { (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") }
function Log([string]$msg, [System.ConsoleColor]$color = [System.ConsoleColor]::White) {
    Write-Host "[$(TS)] $msg" -ForegroundColor $color
}
function Fail([string]$msg, [int]$code = 1) {
    Log $msg Red
    exit $code
}

try {
    Log "=== push_repo.ps1 ===" White
    Log "Message: $Message" Yellow
    Log ("Mode   : " + ($(if ($All) { "ADD_ALL (-A)" } else { "SAFE_ADD" }))) Yellow
    Write-Host ""

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Fail "ERRORE: git non trovato nel PATH." 1
    }

    # Branch corrente
    $branch = (git rev-parse --abbrev-ref HEAD).Trim()
    if (-not $branch -or $branch -eq "HEAD") {
        Fail "ERRORE: sei in DETACHED HEAD. Checkout un branch prima di pushare." 2
    }

    Log "Branch corrente: $branch" Cyan

    # Stato iniziale
    $status = git status --porcelain
    if (-not $status) {
        Log "Nessuna modifica da committare/pushare." Green
        exit 0
    }

    Log "Cambiamenti rilevati (git status --porcelain):" Cyan
    $status | ForEach-Object { Write-Host "  $_" }
    Write-Host ""

    # Add
    if ($All) {
        Log "git add -A" Cyan
        git add -A
    } else {
        # SAFE_ADD: aggiunge modifiche tracked + nuovi file, ma NON cancellazioni involontarie fuori percorso
        # (in pratica: add -u + add di file nuovi, ma sempre visibili dal status sopra)
        Log "git add -u" Cyan
        git add -u
        Log "git add ." Cyan
        git add .
    }
    if ($LASTEXITCODE -ne 0) { Fail "git add fallito." $LASTEXITCODE }

    # Mostra cosa andrà in commit
    Log "Staged diff (summary):" Cyan
    git diff --cached --stat
    Write-Host ""

    # Se non c'è nulla staged, esci
    $staged = git diff --cached --name-only
    if (-not $staged) {
        Log "Nulla in stage. Esco senza commit." Yellow
        exit 0
    }

    # Commit
    Log "git commit -m ""$Message""" Cyan
    git commit -m "$Message"
    if ($LASTEXITCODE -ne 0) { Fail "git commit fallito (forse nulla da committare?)." $LASTEXITCODE }

    # Push: imposta upstream se manca
    $upstream = ""
    try { $upstream = (git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>$null).Trim() } catch { $upstream = "" }

    if (-not $upstream) {
        Log "Nessun upstream impostato. Imposto: origin/$branch" Yellow
        git push -u origin $branch
        if ($LASTEXITCODE -ne 0) { Fail "git push -u fallito." $LASTEXITCODE }
    } else {
        Log "Push su $upstream" Cyan
        git push
        if ($LASTEXITCODE -ne 0) { Fail "git push fallito." $LASTEXITCODE }
    }

    Log "Push completato con successo." Green
    exit 0
}
finally {
    Pop-Location
}
