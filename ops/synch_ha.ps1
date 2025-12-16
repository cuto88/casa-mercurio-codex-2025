###############################################################################
# synch_ha.ps1 — Sincronizza repo locale → Home Assistant
# Modalità MIRROR: le cartelle whitelist sono rese IDENTICHE alla sorgente
# - Aggiunge/Aggiorna file nuovi o modificati
# - Elimina file/cartelle presenti in HA ma non più nel repo
# Cartelle: packages/, mirai/, lovelace/, logica/
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
$HA_ROOT = "Z:\\config"                              # root cartella config HA (es. \\homeassistant\\config)

$excludedRootContent = @("ops", "tools", "docs", "www", ".git", "backup", "export", "deps", "tts", "custom_components")
$excludeFiles = @("*.tmp", "*.log", "home-assistant*.db*", ".DS_Store", "thumbs.db")

# === FUNZIONI ===
function Mirror-Folder {
  param(
    [string]$Source,
    [string]$Destination
  )

  $src = Join-Path $SRC $Source
  $dst = Join-Path $HA_ROOT $Destination

  if (-not (Test-Path $src)) {
    Write-Log "[SKIP] Sorgente non trovata: $src" Yellow
    return 0
  }

  if (-not (Test-Path $dst)) {
    New-Item -ItemType Directory -Path $dst -Force | Out-Null
  }

  Write-Log "[MIRROR] $src -> $dst" Cyan

  $args = @($src, $dst, "/MIR", "/Z", "/R:1", "/W:1", "/NFL", "/NDL", "/NJH", "/NJS", "/NP")
  if ($excludeFiles.Count -gt 0) { $args += @("/XF") + $excludeFiles }

  robocopy @args | Out-Null

  $exitCode = $LASTEXITCODE
  if ($exitCode -ge 8) {
    Write-Log "[ERRORE] Robocopy ha restituito codice $exitCode su $Destination" Red
  }

  return $exitCode
}

# === WHITELIST CARTELLE DA MIRRORARE 1:1 ===
$foldersToMirror = @(
  @{ Source = "packages"; Destination = "packages" },
  @{ Source = "mirai"; Destination = "mirai" },
  @{ Source = "logica"; Destination = "logica" },
  @{ Source = "lovelace"; Destination = "lovelace" }
)

$results = @()
foreach ($map in $foldersToMirror) {
  $code = Mirror-Folder -Source $map.Source -Destination $map.Destination
  $results += [PSCustomObject]@{
    Target = $map.Destination
    ExitCode = $code
  }
}

Write-Host ""
Write-Log "Riepilogo sync (Robocopy exit codes):" Cyan
foreach ($result in $results) {
  Write-Host ("- {0} -> {1}" -f $result.Target, $result.ExitCode)
}

$maxExit = ($results | Measure-Object ExitCode -Maximum).Maximum
Write-Log ("Robocopy exit code massimo: {0}" -f $maxExit) Green
Write-Log ("ℹ️  Esclusi dalla sync: " + ($excludedRootContent -join ", ")) Yellow
Write-Host ""
