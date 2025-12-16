###############################################################################
# synch_ha.ps1 — Sincronizza repo locale → Home Assistant
# Modalità MIRROR: le cartelle whitelist sono rese IDENTICHE alla sorgente
# - Aggiunge/Aggiorna file nuovi o modificati
# - Elimina file/cartelle presenti in HA ma non più nel repo
# Cartelle: packages/, mirai/runtime/, lovelace/, logica/ + configuration.yaml
###############################################################################

$ErrorActionPreference = "Stop"

function Write-Log {
  param(
    [string]$Message,
    [System.ConsoleColor]$Color = [System.ConsoleColor]::White
  )

  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

# === CONFIG ===
$SRC = "C:\\_Tools\\casa-mercurio-codex-2025"   # repo locale
$DST = "Z:\\"                                  # root cartella config HA (es. \\homeassistant\\config)

$excludeDirs = @(".storage", "backups")
$excludeFiles = @("secrets.yaml", "*.db", "*.log")

# === FUNZIONI ===
function Mirror-Folder {
  param(
    [string]$Source,
    [string]$Destination
  )

  $src = Join-Path $SRC $Source
  $dst = Join-Path $DST $Destination

  if (-not (Test-Path $src)) {
    Write-Log "[SKIP] Sorgente non trovata: $src" Yellow
    return
  }

  if (-not (Test-Path $dst)) {
    New-Item -ItemType Directory -Path $dst -Force | Out-Null
  }

  Write-Log "[MIRROR] $src -> $dst" Cyan

  $args = @($src, $dst, "/MIR", "/Z", "/R:1", "/W:1", "/NFL", "/NDL", "/NJH", "/NJS", "/NP")
  if ($excludeDirs.Count -gt 0) { $args += @("/XD") + $excludeDirs }
  if ($excludeFiles.Count -gt 0) { $args += @("/XF") + $excludeFiles }

  robocopy @args | Out-Null

  if ($LASTEXITCODE -ge 8) {
    Write-Log "[ERRORE] Robocopy ha restituito codice $LASTEXITCODE su $Destination" Red
  }
}

function Sync-File {
  param(
    [string]$RelPath
  )

  $srcFile = Join-Path $SRC $RelPath
  $dstFile = Join-Path $DST $RelPath

  if (-not (Test-Path $srcFile)) {
    Write-Log "[SKIP] File sorgente non trovato: $srcFile" Yellow
    return
  }

  $dstDir = Split-Path -Path $dstFile -Parent
  if (-not (Test-Path $dstDir)) {
    New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
  }

  Copy-Item -Path $srcFile -Destination $dstFile -Force
  Write-Log "[FILE] $srcFile -> $dstFile" Green
}

# === WHITELIST CARTELLE DA MIRRORARE 1:1 ===
$foldersToMirror = @(
  @{ Source = "packages"; Destination = "packages" },
  @{ Source = "mirai\\runtime"; Destination = "mirai" },
  @{ Source = "lovelace"; Destination = "lovelace" },
  @{ Source = "logica"; Destination = "logica" }
)

foreach ($map in $foldersToMirror) {
  Mirror-Folder -Source $map.Source -Destination $map.Destination
}

# === FILE SINGOLI ===
Sync-File -RelPath "configuration.yaml"

Write-Host ""
Write-Log "✅ Sync completato (mirror cartelle + configuration.yaml)." Green
Write-Host ""
