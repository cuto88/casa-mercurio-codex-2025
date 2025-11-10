@echo off
setlocal enabledelayedexpansion

REM === watch_remote.cmd ===
REM Monitora GitHub; se ci sono nuovi commit: pull_repo.ps1 -> (10s) -> synch_ha.ps1

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

REM 2) Controlla aggiornamenti remoti
git fetch origin %BRANCH% >nul 2>&1
for /f "delims=" %%A in ('git rev-parse HEAD') do set "LOCAL=%%A"
for /f "delims=" %%A in ('git rev-parse origin/%BRANCH%') do set "REMOTE=%%A"

if not "%LOCAL%"=="%REMOTE%" (
    echo ⬇️  Nuovi commit su GitHub:
    echo     local : %LOCAL%
    echo     remote: %REMOTE%
    echo.

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

    echo ⏳ Attendo %POST_PULL_WAIT%s, poi sincronizzo HA...
    timeout /t %POST_PULL_WAIT% /nobreak >nul

    powershell -ExecutionPolicy Bypass -File "%SYNC_SCRIPT%"
    if errorlevel 1 (
        echo ❌ Sync fallito. Controlla synch_ha.ps1.
    ) else (
        echo ✅ Sync completato.
    )
) else (
    echo ⏳ Nessuna novità. Ricontrollo tra %CHECK_INTERVAL%s...
    timeout /t %CHECK_INTERVAL% /nobreak >nul
)

goto LOOP
