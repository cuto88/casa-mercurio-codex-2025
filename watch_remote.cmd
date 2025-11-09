@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM === WATCH_REMOTE.CMD — Monitoraggio repo GitHub + sync Home Assistant ===

set "REPO_PATH=C:\_Tools\casa-mercurio-codex-2025"
set "PULL_SCRIPT=%REPO_PATH%\pull_repo.ps1"
set "SYNC_SCRIPT=%REPO_PATH%\synch_ha.ps1"
set "INTERVAL=30"

:LOOP
cls
echo =====================================================
echo [%date% %time%] Monitoraggio repository attivo...
echo =====================================================

cd /d "%REPO_PATH%"

REM Controlla modifiche locali non committate
set "CHANGES_COUNT=0"
for /f "tokens=*" %%i in ('git status --porcelain') do (
    set /a CHANGES_COUNT+=1
)

if %CHANGES_COUNT% gtr 0 (
    echo [%time%] ⚠️  %CHANGES_COUNT% modifiche locali rilevate: eseguo pull_repo.ps1...
    if exist "%PULL_SCRIPT%" (
        powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& '%PULL_SCRIPT%'"
    ) else (
        echo [%time%] ❌ ERRORE: pull_repo.ps1 non trovato in %PULL_SCRIPT%
    )
    timeout /t 10 >nul
    echo [%time%] Avvio sincronizzazione Home Assistant...
    if exist "%SYNC_SCRIPT%" (
        powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& '%SYNC_SCRIPT%'"
    ) else (
        echo [%time%] ❌ ERRORE: synch_ha.ps1 non trovato in %SYNC_SCRIPT%
    )
) else (
    echo [%time%] Nessuna modifica locale, nessuna azione necessaria.
)

echo.
echo [%time%] Prossimo controllo tra %INTERVAL% secondi...
timeout /t %INTERVAL% >nul
goto LOOP
