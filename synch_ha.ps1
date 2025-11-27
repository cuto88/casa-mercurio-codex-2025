###############################################################################
# synch_ha.ps1 — Sincronizza repo locale → Home Assistant
# Modalità MIRROR: le cartelle whitelist sono rese IDENTICHE alla sorgente
# - Aggiunge/Aggiorna file nuovi o modificati
# - Elimina file/cartelle presenti in HA ma non più nel repo
# Cartelle: logica/, lovelace/, packages/ + configuration.yaml
###############################################################################

$ErrorActionPreference = "Stop"

# === CONFIG ===
$SRC = "C:\_Tools\casa-mercurio-codex-2025"   # repo locale
$DST = "Z:\"                                  # root cartella config HA (es. \\homeassistant\config)

# === FUNZIONI ===
function Mirror-Folder {
  param(
    [string]$Folder
  )

  $src = Join-Path $SRC $Folder
  $dst = Join-Path $DST $Folder

  if (-not (Test-Path $src)) {
    Write-Host "[SKIP] Sorgente non trovata: $src" -ForegroundColor Yellow
    return
  }

  if (-not (Test-Path $dst)) {
    New-Item -ItemType Directory -Path $dst -Force | Out-Null
  }

  Write-Host "[MIRROR] $src -> $dst"

  # /MIR  = mirror completo (copy + delete)
  # /Z    = copia riavviabile
  # /R:1  = 1 solo tentativo di retry
  # /W:1  = attesa 1s tra i retry
  # /NFL /NDL /NJH /NJS /NP = output compatto
  robocopy $src $dst /MIR /Z /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null

  if ($LASTEXITCODE -ge 8) {
    Write-Host "[ERRORE] Robocopy ha restituito codice $LASTEXITCODE su $Folder" -ForegroundColor Red
  }
}

function Sync-File {
  param(
    [string]$RelPath
  )

  $srcFile = Join-Path $SRC $RelPath
  $dstFile = Join-Path $DST $RelPath

  if (-not (Test-Path $srcFile)) {
    Write-Host "[SKIP] File sorgente non trovato: $srcFile" -ForegroundColor Yellow
    return
  }

  $dstDir = Split-Path -Path $dstFile -Parent
  if (-not (Test-Path $dstDir)) {
    New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
  }

  Copy-Item -Path $srcFile -Destination $dstFile -Force
  Write-Host "[FILE] $srcFile -> $dstFile"
}

# === WHITELIST CARTELLE DA MIRRORARE 1:1 ===
$foldersToMirror = @("logica", "lovelace", "packages")

foreach ($folder in $foldersToMirror) {
  Mirror-Folder -Folder $folder
}

# === FILE SINGOLI ===
Sync-File -RelPath "configuration.yaml"

Write-Host ""
Write-Host "✅ Sync completato (mirror cartelle + configuration.yaml)." -ForegroundColor Green
Write-Host ""
