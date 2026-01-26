$ErrorActionPreference = 'Stop'

Write-Host "==> SYNC + GATES"

# 1. Sync hard con origin/main
git fetch origin
git reset --hard origin/main

# 2. Run gates
powershell -NoProfile -ExecutionPolicy Bypass -File ops\run_gates.ps1

Write-Host "==> OK: repo allineato e gates verdi"
