@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM === WATCH_REMOTE.CMD — Controllo nuovi commit su GitHub + sync HA ===

set "BRANCH=main"
set "CHECK_INTERVAL=30"   REM secondi tra i controlli
set "POST_PULL_WAIT=10"   REM attesa prima del sync
if "%IGNORE_LOCAL_CHANGES%"=="" set "IGNORE_LOCAL_CHANGES=0"

set "PULL_SCRIPT=%~dp0pull_repo.ps1"
set "SYNC_SCRIPT=%~dp0synch_ha.ps1"

echo 🔁 Watcher remoto avviato (branch: %BRANCH%)
echo Repo: %cd%
echo.

:LOOP
if /I not "%IGNORE_LOCAL_CHANGES%"=="1" (
  REM 1) Blocca se ci sono modifiche locali (ignora untracked)
  git diff --quiet
  if not "%ERRORLEVEL%"=="0" (
    echo ⚠️  Modifiche locali non committate → skip pull
    timeout /t %CHECK_INTERVAL% /nobreak >nul
    goto LOOP
  )
  git diff --cached --quiet
  if not "%ERRORLEVEL%"=="0" (
    echo ⚠️  Modifiche in stage → skip pull
    timeout /t %CHECK_INTERVAL% /nobreak >nul
    goto LOOP
  )
) else (
  echo 🔓 Ignoro modifiche locali (variabile IGNORE_LOCAL_CHANGES=1)
)

REM Aggiorna info da remoto
git fetch origin >nul 2>&1

set "REMOTE_AHEAD=0"
for /f "delims=" %%c in ('git rev-list HEAD..origin/!BRANCH! --count') do set "REMOTE_AHEAD=%%c"

    if /I "%IGNORE_LOCAL_CHANGES%"=="1" (
        powershell -ExecutionPolicy Bypass -File "%PULL_SCRIPT%" -IgnoreLocalChanges
    ) else (
        powershell -ExecutionPolicy Bypass -File "%PULL_SCRIPT%"
    )
    if errorlevel 1 (
        echo ❌ Pull fallito. Riprovo tra %CHECK_INTERVAL%s...
        timeout /t %CHECK_INTERVAL% /nobreak >nul
        goto LOOP
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
