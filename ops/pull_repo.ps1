# ops\pull_repo.ps1
# Pull repo from origin safely (default). Force reset only if explicitly requested.
# Compatible with Windows PowerShell 5.1

[CmdletBinding()]
param(
    [switch]$ForceReset
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

function Fail([string]$Message, [int]$Code = 1) {
    Write-Log $Message Red
    exit $Code
}

try {
    Write-Log "=== pull_repo.ps1 ===" White
    Write-Log ("Mode = " + ($(if ($ForceReset) { "FORCE_RESET" } else { "SAFE" }))) Yellow
    Write-Host ""

    # Verifica git
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Fail "ERRORE: git non trovato nel PATH." 1
    }

    # Determina branch corrente
    $branch = (git rev-parse --abbrev-ref HEAD).Trim()
    if (-not $branch) { $branch = "main" }

    Write-Log "Branch corrente: $branch" Cyan
    Write-Host ""

    if ($ForceReset) {
        Write-Log "ATTENZIONE: FORCE_RESET distrugge modifiche locali e file non tracciati." Yellow
        Write-Log "Fetch origin/$branch ..." Cyan
        git fetch origin $branch
        if ($LASTEXITCODE -ne 0) { Fail "git fetch fallito." $LASTEXITCODE }

        Write-Log "Reset hard su origin/$branch ..." Cyan
        git reset --hard ("origin/" + $branch)
        if ($LASTEXITCODE -ne 0) { Fail "git reset --hard fallito." $LASTEXITCODE }

        Write-Log "Pulizia file non tracciati (git clean -fd) ..." Cyan
        git clean -fd
        if ($LASTEXITCODE -ne 0) { Fail "git clean fallito." $LASTEXITCODE }

    } else {
        Write-Log "Modalita SAFE: blocco se ci sono modifiche locali." Cyan

        # Blocca se working tree non pulito
        $status = git status --porcelain
        if ($status) {
            Write-Host ""
            Write-Log "Working tree DIRTY: ci sono modifiche non committate." Yellow
            Write-Log "Azioni possibili:" Yellow
            Write-Log "  1) Commit: git add -A ; git commit -m ""msg""" Yellow
            Write-Log "  2) Stash:  git stash push -m ""WIP""" Yellow
            Write-Log "  3) FORZA (perdi modifiche): ops\pull_repo.ps1 -ForceReset" Yellow
            exit 2
        }

        Write-Log "Fetch origin/$branch ..." Cyan
        git fetch origin $branch
        if ($LASTEXITCODE -ne 0) { Fail "git fetch fallito." $LASTEXITCODE }

        Write-Log "Pull ff-only origin/$branch ..." Cyan
        git pull --ff-only origin $branch
        if ($LASTEXITCODE -ne 0) { Fail "git pull --ff-only fallito." $LASTEXITCODE }
    }

    Write-Host ""
    Write-Log "Pull completato con successo." Green
    exit 0
}
finally {
    Pop-Location
}
