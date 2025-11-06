
# === backup_yamls.ps1 ===
# Backup dei file YAML e DISABLED dalla cartella \\192.168.178.84\config\
# NOTA: -Include funziona solo con -Recurse oppure con un wildcard nel -Path.
#       Usiamo quindi "$source\*" per selezionare correttamente i file.

$ErrorActionPreference = "Stop"

$source = "\\192.168.178.84\config\"
$today  = Get-Date -Format "yyyyMMdd"
$dest   = Join-Path $source ("backup\" + $today)

# Crea destinazione se non esiste
if (!(Test-Path $dest)) {
    New-Item -ItemType Directory -Path $dest | Out-Null
}

try {
    # Seleziona i file con wildcard nel percorso (no sottocartelle)
    $items = Get-ChildItem -Path (Join-Path $source '*') -Include *.yaml,*.disabled -File

    if ($items.Count -eq 0) {
        Write-Host "Nessun file .yaml o .disabled trovato in $source"
    } else {
        foreach ($f in $items) {
            Copy-Item -LiteralPath $f.FullName -Destination $dest -Force
        }
        Write-Host ("Copiati {0} file in: {1}" -f $items.Count, $dest)
    }
}
catch {
    Write-Host "Errore durante il backup: $($_.Exception.Message)"
    exit 1
}
