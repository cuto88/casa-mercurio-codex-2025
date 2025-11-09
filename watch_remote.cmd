@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM === WATCH_REMOTE.CMD — Controllo nuovi commit su GitHub + sync HA ===

set "REPO_PATH=C:\_Tools\casa-mercurio-codex-2025"
set "PULL_SCRIPT=%REPO_PATH%\pull_repo.ps1"
set "SYNC_SCRIPT=%REPO_PATH%\synch_ha.ps1"
set "INTERVAL=30"

:LOOP
cls
echo =====================================================
echo [%date% %time%] Monitoraggio repository attivo...
echo =====================================================

cd /d "%REPO_PATH%" || (
    echo [%time%] ERRORE: impossibile accedere alla cartella %REPO_PATH%
    echo [%time%] Prossimo controllo tra %INTERVAL% secondi...
    timeout /t %INTERVAL% >nul
    goto LOOP
)

REM Branch corrente
set "BRANCH="
for /f "delims=" %%b in ('git rev-parse --abbrev-ref HEAD') do set "BRANCH=%%b"

if not defined BRANCH (
    echo [%time%] ERRORE: impossibile determinare il branch corrente.
    echo [%time%] Prossimo controllo tra %INTERVAL% secondi...
    timeout /t %INTERVAL% >nul
    goto LOOP
)

REM Aggiorna info da remoto
git fetch origin >nul 2>&1

set "REMOTE_AHEAD=0"
for /f "delims=" %%c in ('git rev-list HEAD..origin/!BRANCH! --count') do set "REMOTE_AHEAD=%%c"

if "!REMOTE_AHEAD!" NEQ "0" (
    echo [%time%] Trovati !REMOTE_AHEAD! nuovi commit su origin/!BRANCH!.
    
    if exist "%PULL_SCRIPT%" (
        echo [%time%] Eseguo pull_repo.ps1...
        powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PULL_SCRIPT%"
    ) else (
        echo [%time%] ERRORE: pull_repo.ps1 non trovato in %PULL_SCRIPT%
    )

    echo [%time%] Avvio synch_ha.ps1...
    if exist "%SYNC_SCRIPT%" (
        powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SYNC_SCRIPT%"
    ) else (
        echo [%time%] ERRORE: synch_ha.ps1 non trovato in %SYNC_SCRIPT%
    )
) else (
    echo [%time%] Nessun nuovo commit su origin/!BRANCH!. Nessuna azione.
)

echo.
echo [%time%] Prossimo controllo tra %INTERVAL% secondi...
timeout /t %INTERVAL% >nul
goto LOOP
