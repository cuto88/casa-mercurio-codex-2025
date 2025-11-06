###############################################################################
# synch_ha.ps1 — Sincronizza repo locale → Home Assistant
# Copia solo le cartelle whitelist: packages/, lovelace/, logica/, configuration.yaml
###############################################################################

# === CONFIG ===
$SRC = "C:\_Tools\casa-mercurio-codex-2025"   # repo locale
$DST = "Z:\"                                  # root cartella config HA (es. \\homeassistant\config)

# === FUNZIONI ===
function Sync-Dir($subpath) {
  $srcPath = Join-Path $SRC $subpath
  $dstPath = Join-Path $DST $subpath
  if (Test-Path $srcPath) {
    # crea la dir di destinazione se non esiste
    New-Item -ItemType Directory -Path $dstPath -Force | Out-Null
    robocopy $srcPath $dstPath /E /FFT /XO /XD ".git" ".vscode" /NFL /NDL /NP /R:1 /W:1 | Out-Null
    Write-Host ("[DIR]  {0} -> {1}" -f $subpath, $dstPath)
  }
}

function Sync-File($relfile) {
  $srcFile = Join-Path $SRC $relfile
  $dstFile = Join-Path $DST $relfile
  if (Test-Path $srcFile) {
    $dstDir = Split-Path -Path $dstFile -Parent
    # crea la cartella di destinazione solo se NON è la root e non esiste già
    if ($dstDir -and (Test-Path -Path $dstDir) -eq $false -and ($dstDir -notmatch '^[A-Za-z]:\\$')) {
      New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    }
    Copy-Item $srcFile $dstFile -Force
    Write-Host ("[FILE] {0} -> {1}" -f $relfile, $dstFile)
  }
}

# === WHITELIST ===
Sync-Dir  "packages"
Sync-Dir  "lovelace"
Sync-Dir  "logica"                  # documentazione ignorata da HA
Sync-File "configuration.yaml"

Write-Host ""
Write-Host "✅ Sync completato."
Write-Host ""
Read-Host "Premi INVIO per chiudere..."
