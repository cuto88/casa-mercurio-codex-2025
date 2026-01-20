# Quarantine notes

Data: 2026-01-20

Motivo: backup potenzialmente attivo perché packages è incluso in blocco.

Spostato:
- packages/mirai.yaml.bak-20251228-0849 → /_quarantine/20260120_cleanup/packages/mirai.yaml.bak-20251228-0849

Rollback (comando):
- Bash: mv /_quarantine/20260120_cleanup/packages/mirai.yaml.bak-20251228-0849 packages/mirai.yaml.bak-20251228-0849
- PowerShell: Move-Item /_quarantine/20260120_cleanup/packages/mirai.yaml.bak-20251228-0849 packages/mirai.yaml.bak-20251228-0849

Gate da eseguire:
- Bash (HA CLI): ha core check
- Bash (python): python -m homeassistant --script check_config -c <CONFIG_DIR>
- PowerShell (HA CLI): ha core check
- PowerShell (python): python -m homeassistant --script check_config -c <CONFIG_DIR>
