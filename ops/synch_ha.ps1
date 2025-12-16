###############################################################################
# synch_ha.ps1 — Sincronizza repo locale → Home Assistant
# Modalità MIRROR: le cartelle whitelist sono rese IDENTICHE alla sorgente
# - Aggiunge/Aggiorna file nuovi o modificati
# - Elimina file/cartelle presenti in HA ma non più nel repo
# Cartelle: packages/, mirai/, lovelace/, logica/, www/, custom_components/, blueprints/ + configuration.yaml
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
$RepoRoot = Split-Path -Path $PSScriptRoot -Parent   # root della repo (cartella padre di ops/)
$SRC = $RepoRoot                                     # repo locale
$DST = "Z:\\config"                                  # root cartella config HA (es. \\homeassistant\\config)

$excludeDirs = @(".storage", "backups")
$excludeFiles = @("secrets.yaml", "*.db", "*.log")
$excludedRootContent = @("ops", "tools", "docs", "README.md", "README_ClimaSystem.md")

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
  @{ Source = "mirai"; Destination = "mirai" },
  @{ Source = "logica"; Destination = "logica" },
  @{ Source = "lovelace"; Destination = "lovelace" },
  @{ Source = "www"; Destination = "www" },
  @{ Source = "custom_components"; Destination = "custom_components" },
  @{ Source = "blueprints"; Destination = "blueprints" }
)

foreach ($map in $foldersToMirror) {
  Mirror-Folder -Source $map.Source -Destination $map.Destination
}

# === FILE SINGOLI ===
Sync-File -RelPath "configuration.yaml"

Write-Host ""
Write-Log "✅ Sync completato (mirror cartelle + configuration.yaml)." Green
Write-Log ("ℹ️  Esclusi dalla sync: " + ($excludedRootContent -join ", ")) Yellow
Write-Host ""
