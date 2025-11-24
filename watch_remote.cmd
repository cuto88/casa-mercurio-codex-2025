@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM WATCH_REMOTE.CMD — Controllo nuovi commit su GitHub + sync HA
REM Versione semplificata: ignora SEMPRE modifiche locali lato repo

REM 1) Determina il branch corrente come default
set "DEFAULT_BRANCH="
for /f "delims=" %%B in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set "DEFAULT_BRANCH=%%B"
if "%DEFAULT_BRANCH%"=="" set "DEFAULT_BRANCH=main"

REM 2) Impostazioni base
set "BRANCH=%DEFAULT_BRANCH%"
set "CHECK_INTERVAL=30"
set "IGNORE_LOCAL_CHANGES=1"

REM 3) Parsing argomenti opzionali
:PARSE_ARGS
if "%~1"=="" goto ARGS_DONE

if /I "%~1"=="--branch" (
  if not "%~2"=="" (
    set "BRANCH=%~2"
    shift
  )
  shift
  goto PARSE_ARGS
)

for %%A in (--ignore-local -ignore-local /ignore-local ignore-local --ignore -ignore /ignore ignore) do (
  if /I "%~1"=="%%~A" set "IGNORE_LOCAL_CHANGES=1"
)

shift
goto PARSE_ARGS

:ARGS_DONE
if "%BRANCH%"=="" set "BRANCH=%DEFAULT_BRANCH%"
set "WATCH_BRANCH=%BRANCH%"

set "PULL_SCRIPT=%~dp0pull_repo.ps1"
set "SYNC_SCRIPT=%~dp0synch_ha.ps1"

echo 🔁 Watcher remoto avviato \(branch: %BRANCH%\)
echo Repo: %cd%
echo Ignoro SEMPRE le modifiche locali \(reset/pull forzato gestito da pull_repo.ps1\)
echo.

:LOOP
echo [%time%] Controllo nuovi commit su origin/%BRANCH%...

git fetch origin %BRANCH% >nul 2>&1
for /f "delims=" %%A in ('git rev-parse HEAD') do set "LOCAL=%%A"
for /f "delims=" %%A in ('git rev-parse origin/%BRANCH%') do set "REMOTE=%%A"

if not "%LOCAL%"=="%REMOTE%" (
    echo ⬇️  Nuovi commit su GitHub:
    echo     local : %LOCAL%
    echo     remote: %REMOTE%
    echo.

    REM Pull forzato: sempre -IgnoreLocalChanges
    powershell -ExecutionPolicy Bypass -File "%PULL_SCRIPT%" -IgnoreLocalChanges
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
    echo [%time%] Nessun nuovo commit su origin/%BRANCH%. Nessuna azione.
)

echo.
echo [%time%] Prossimo controllo tra %CHECK_INTERVAL% secondi...
timeout /t %CHECK_INTERVAL% /nobreak >nul
goto LOOP
