###############################################################################
# synch_ha.ps1 — Sincronizza repo locale → Home Assistant
# Copia solo le cartelle whitelist: packages/, lovelace/, logica/, configuration.yaml
###############################################################################

# === CONFIG ===
$SRC = "C:\_Tools\casa-mercurio-codex-2025"   # repo locale
$DST = "Z:\"                                  # root cartella config HA (es. \\homeassistant\config)

# === FUNZIONI ===
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

function Mirror-Folders($folders) {
  foreach ($folder in $folders) {
    $src = Join-Path $SRC $folder
    $dst = Join-Path $DST $folder

    if (Test-Path $src) {
      New-Item -ItemType Directory -Path $dst -Force | Out-Null
      robocopy $src $dst /MIR /XO /XD ".git" ".storage" "backup" /NFL /NDL /NP /R:1 /W:1 | Out-Null
      Write-Host ("[MIRROR] {0} -> {1}" -f $folder, $dst)
    }
  }
}

# === WHITELIST ===
$foldersToMirror = @("logica", "lovelace", "packages")

Mirror-Folders $foldersToMirror
Sync-File "configuration.yaml"

Write-Host ""
Write-Host "✅ Sync completato."
Write-Host ""
