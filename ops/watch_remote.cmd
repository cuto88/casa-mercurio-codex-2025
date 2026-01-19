@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM WATCH_REMOTE.CMD — Watch origin/BRANCH and (optionally) sync HA
REM SAFE by default: never destroys local changes unless --force-reset is provided.

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "REPO_ROOT=%%~fI"
pushd "%REPO_ROOT%"

REM Runner PowerShell: prefer pwsh if available, else powershell
set "PSRUN=powershell"
where pwsh >nul 2>nul && set "PSRUN=pwsh"

REM Default branch = current branch
set "DEFAULT_BRANCH="
for /f "delims=" %%B in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set "DEFAULT_BRANCH=%%B"
if "%DEFAULT_BRANCH%"=="" set "DEFAULT_BRANCH=main"

REM Defaults
set "BRANCH=%DEFAULT_BRANCH%"
set "CHECK_INTERVAL=30"
set "DO_SYNC=1"
set "FORCE_RESET=0"

REM Scripts (in ops\)
set "PULL_SCRIPT=%SCRIPT_DIR%pull_repo.ps1"
set "SYNC_SCRIPT=%SCRIPT_DIR%synch_ha.ps1"

REM Args:
REM   --branch NAME
REM   --interval SECONDS
REM   --no-sync
REM   --sync
REM   --force-reset
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

if /I "%~1"=="--interval" (
  if not "%~2"=="" (
    set "CHECK_INTERVAL=%~2"
    shift
  )
  shift
  goto PARSE_ARGS
)

if /I "%~1"=="--no-sync" (
  set "DO_SYNC=0"
  shift
  goto PARSE_ARGS
)

if /I "%~1"=="--sync" (
  set "DO_SYNC=1"
  shift
  goto PARSE_ARGS
)

if /I "%~1"=="--force-reset" (
  set "FORCE_RESET=1"
  shift
  goto PARSE_ARGS
)

shift
goto PARSE_ARGS

:ARGS_DONE
if "%BRANCH%"=="" set "BRANCH=%DEFAULT_BRANCH%"

echo.
echo ===========================================
echo  🔁 Watcher avviato
echo  Repo      : %cd%
echo  Branch    : %BRANCH%
echo  PS     : %PSRUN%
if "%FORCE_RESET%"=="1" (
  echo  Modalita : FORCE (distrugge modifiche locali)
) else (
  echo  Modalita : SAFE (non distrugge modifiche locali)
)
if "%DO_SYNC%"=="1" (
  echo  Sync     : ON  (synch_ha.ps1 dopo pull)
) else (
  echo  Sync     : OFF (solo pull)
)
echo  Every : %CHECK_INTERVAL%s
echo ===========================================
echo.

:LOOP
set "LOCAL="
set "REMOTE="
echo [%time%] Fetch origin/%BRANCH% ...

git fetch origin %BRANCH% >nul 2>&1
if errorlevel 1 (
  echo [%time%] ❌ ERRORE: git fetch fallito. Attendo %CHECK_INTERVAL%s e riprovo.
  timeout /t %CHECK_INTERVAL% /nobreak >nul
  goto LOOP
)

for /f "delims=" %%A in ('git rev-parse HEAD 2^>nul') do set "LOCAL=%%A"
for /f "delims=" %%A in ('git rev-parse origin/%BRANCH% 2^>nul') do set "REMOTE=%%A"

if "%LOCAL%"=="" (
  echo [%time%] ❌ ERRORE: impossibile leggere HEAD locale.
  timeout /t %CHECK_INTERVAL% /nobreak >nul
  goto LOOP
)

if "%REMOTE%"=="" (
  echo [%time%] ❌ ERRORE: impossibile leggere origin/%BRANCH%.
  timeout /t %CHECK_INTERVAL% /nobreak >nul
  goto LOOP
)

if not "%LOCAL%"=="%REMOTE%" (
  echo [%time%] ⬇️  Nuovi commit trovati:
  echo     local : %LOCAL%
  echo     remote: %REMOTE%
  echo.

  if not exist "%PULL_SCRIPT%" (
    echo [%time%] ❌ ERRORE: pull_repo.ps1 non trovato: %PULL_SCRIPT%
    timeout /t %CHECK_INTERVAL% /nobreak >nul
    goto LOOP
  )

  REM Pull SAFE / FORCE
  if "%FORCE_RESET%"=="1" (
    %PSRUN% -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PULL_SCRIPT%" -ForceReset
  ) else (
    %PSRUN% -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PULL_SCRIPT%"
  )

  REM pull_repo SAFE returns 2 if working tree dirty (by our implementation)
  if errorlevel 2 (
    echo [%time%] ⚠️ Repo DIRTY: pull bloccato (SAFE). Nessuna sync. Risolvi e riparto.
    timeout /t %CHECK_INTERVAL% /nobreak >nul
    goto LOOP
  )

  if errorlevel 1 (
    echo [%time%] ❌ Pull fallito. Riprovo tra %CHECK_INTERVAL%s...
    timeout /t %CHECK_INTERVAL% /nobreak >nul
    goto LOOP
  )

  if "%DO_SYNC%"=="1" (
    echo [%time%] ▶ Avvio synch_ha.ps1...
    if exist "%SYNC_SCRIPT%" (
      %PSRUN% -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SYNC_SCRIPT%"
      if errorlevel 1 (
        echo [%time%] ❌ synch_ha.ps1 fallito. Controlla output sopra.
      )
    ) else (
      echo [%time%] ❌ ERRORE: synch_ha.ps1 non trovato: %SYNC_SCRIPT%
    )
  ) else (
    echo [%time%] Sync disabilitata (--no-sync). Fine azione.
  )

) else (
  echo [%time%] OK: nessun nuovo commit su origin/%BRANCH%. Nessuna azione.
)

echo.
echo [%time%] Prossimo controllo tra %CHECK_INTERVAL% secondi...
timeout /t %CHECK_INTERVAL% /nobreak >nul
goto LOOP
