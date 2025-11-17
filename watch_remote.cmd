@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM === WATCH_REMOTE.CMD — Controllo nuovi commit su GitHub + sync HA ===

set "DEFAULT_BRANCH="
for /f "delims=" %%B in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set "DEFAULT_BRANCH=%%B"
if "%DEFAULT_BRANCH%"=="" set "DEFAULT_BRANCH=main"

if not "%WATCH_BRANCH%"=="" (
  set "BRANCH=%WATCH_BRANCH%"
) else (
  set "BRANCH=%DEFAULT_BRANCH%"
)

set "DEFAULT_BRANCH="
for /f "delims=" %%B in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set "DEFAULT_BRANCH=%%B"
if "%DEFAULT_BRANCH%"=="" set "DEFAULT_BRANCH=main"

if not "%WATCH_BRANCH%"=="" (
  set "BRANCH=%WATCH_BRANCH%"
) else (
  set "BRANCH=%DEFAULT_BRANCH%"
)

set "DEFAULT_BRANCH="
for /f "delims=" %%B in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set "DEFAULT_BRANCH=%%B"
if "%DEFAULT_BRANCH%"=="" set "DEFAULT_BRANCH=main"

if not "%WATCH_BRANCH%"=="" (
  set "BRANCH=%WATCH_BRANCH%"
) else (
  set "BRANCH=%DEFAULT_BRANCH%"
)

set "CHECK_INTERVAL=30"   REM secondi tra i controlli
set "POST_PULL_WAIT=10"   REM attesa prima del sync
if "%IGNORE_LOCAL_CHANGES%"=="" set "IGNORE_LOCAL_CHANGES=0"

REM Flag per ignorare le modifiche locali: accetta variabile ambiente o parametro CLI
if not "%~1"=="" (
  for %%A in (--ignore-local -ignore-local /ignore-local ignore-local --ignore -ignore /ignore ignore) do (
    if /I "%~1"=="%%~A" set "IGNORE_LOCAL_CHANGES=1"
  )
)
if "%IGNORE_LOCAL_CHANGES%"=="" set "IGNORE_LOCAL_CHANGES=0"

REM Flag per ignorare le modifiche locali: accetta variabile ambiente o parametro CLI
if not "%~1"=="" (
  for %%A in (--ignore-local -ignore-local /ignore-local ignore-local --ignore -ignore /ignore ignore) do (
    if /I "%~1"=="%%~A" set "IGNORE_LOCAL_CHANGES=1"
  )
)
if "%IGNORE_LOCAL_CHANGES%"=="" set "IGNORE_LOCAL_CHANGES=0"

REM Flag per ignorare le modifiche locali: accetta variabile ambiente o parametro CLI
if not "%~1"=="" (
  for %%A in (--ignore-local -ignore-local /ignore-local ignore-local --ignore -ignore /ignore ignore) do (
    if /I "%~1"=="%%~A" set "IGNORE_LOCAL_CHANGES=1"
  )
)
if "%IGNORE_LOCAL_CHANGES%"=="" set "IGNORE_LOCAL_CHANGES=0"

REM Flag per ignorare le modifiche locali: accetta variabile ambiente o parametro CLI
if not "%~1"=="" (
  for %%A in (--ignore-local -ignore-local /ignore-local ignore-local --ignore -ignore /ignore ignore) do (
    if /I "%~1"=="%%~A" set "IGNORE_LOCAL_CHANGES=1"
  )
)
if "%IGNORE_LOCAL_CHANGES%"=="" set "IGNORE_LOCAL_CHANGES=0"

REM Flag per ignorare le modifiche locali: accetta variabile ambiente o parametro CLI
set "IGNORE_LOCAL_CHANGES=0"

:PARSE_ARGS
if "%~1"=="" goto ARGS_DONE
for %%A in (--ignore-local -ignore-local /ignore-local ignore-local --ignore -ignore /ignore ignore) do (
  if /I "%~1"=="%%~A" set "IGNORE_LOCAL_CHANGES=1"
)
if /I "%~1"=="--branch" (
  if not "%~2"=="" (
    set "BRANCH=%~2"
    shift
  )
  shift
  goto PARSE_ARGS
)
for /f "tokens=1,2 delims==" %%A in ("%~1") do (
  if /I "%%~A"=="--branch" set "BRANCH=%%~B"
)
shift
goto PARSE_ARGS

:ARGS_DONE
if "%BRANCH%"=="" set "BRANCH=%DEFAULT_BRANCH%"
set "WATCH_BRANCH=%BRANCH%"

REM Flag per ignorare le modifiche locali: accetta variabile ambiente o parametro CLI
set "IGNORE_LOCAL_CHANGES=0"

:PARSE_ARGS
if "%~1"=="" goto ARGS_DONE
for %%A in (--ignore-local -ignore-local /ignore-local ignore-local --ignore -ignore /ignore ignore) do (
  if /I "%~1"=="%%~A" set "IGNORE_LOCAL_CHANGES=1"
)
if /I "%~1"=="--branch" (
  if not "%~2"=="" (
    set "BRANCH=%~2"
    shift
  )
  shift
  goto PARSE_ARGS
)
for /f "tokens=1,2 delims==" %%A in ("%~1") do (
  if /I "%%~A"=="--branch" set "BRANCH=%%~B"
)
shift
goto PARSE_ARGS

:ARGS_DONE
if "%BRANCH%"=="" set "BRANCH=%DEFAULT_BRANCH%"
set "WATCH_BRANCH=%BRANCH%"

REM Flag per ignorare le modifiche locali: accetta variabile ambiente o parametro CLI
set "IGNORE_LOCAL_CHANGES=0"

:PARSE_ARGS
if "%~1"=="" goto ARGS_DONE
for %%A in (--ignore-local -ignore-local /ignore-local ignore-local --ignore -ignore /ignore ignore) do (
  if /I "%~1"=="%%~A" set "IGNORE_LOCAL_CHANGES=1"
)
if /I "%~1"=="--branch" (
  if not "%~2"=="" (
    set "BRANCH=%~2"
    shift
  )
  shift
  goto PARSE_ARGS
)
for /f "tokens=1,2 delims==" %%A in ("%~1") do (
  if /I "%%~A"=="--branch" set "BRANCH=%%~B"
)
shift
goto PARSE_ARGS

:ARGS_DONE
if "%BRANCH%"=="" set "BRANCH=%DEFAULT_BRANCH%"
set "WATCH_BRANCH=%BRANCH%"

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
    echo     Usa "watch_remote.cmd --ignore-local" per ignorarle temporaneamente.
    timeout /t %CHECK_INTERVAL% /nobreak >nul
    goto LOOP
  )
  git diff --cached --quiet
  if not "%ERRORLEVEL%"=="0" (
    echo ⚠️  Modifiche in stage → skip pull
    echo     Usa "watch_remote.cmd --ignore-local" per ignorarle temporaneamente.
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
