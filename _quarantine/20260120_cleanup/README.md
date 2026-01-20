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

---

## Step 2 — Orphan low-risk (2026-01-20)

Nota: nessuna modifica a configuration.yaml in step 2.

Spostato:
- configuration.yaml.bak-20251228-0849 → /_quarantine/20260120_cleanup/orphan_backups/configuration.yaml.bak-20251228-0849
- mirai.bak-20251228-0849/ → /_quarantine/20260120_cleanup/orphan_backups/mirai.bak-20251228-0849/
- www/mirai/00_input_boolean.yaml → /_quarantine/20260120_cleanup/www_orphans/00_input_boolean.yaml
- www/mirai/01_shell_command.yaml → /_quarantine/20260120_cleanup/www_orphans/01_shell_command.yaml
- www/mirai/10_modbus.yaml → /_quarantine/20260120_cleanup/www_orphans/10_modbus.yaml
- www/mirai/20_templates_bits.yaml → /_quarantine/20260120_cleanup/www_orphans/20_templates_bits.yaml
- www/mirai/21_main_signals.yaml → /_quarantine/20260120_cleanup/www_orphans/21_main_signals.yaml
- www/mirai/21_state.yaml → /_quarantine/20260120_cleanup/www_orphans/21_state.yaml
- www/mirai/22_state.yaml → /_quarantine/20260120_cleanup/www_orphans/22_state.yaml
- www/mirai/23_fault.yaml → /_quarantine/20260120_cleanup/www_orphans/23_fault.yaml
- www/mirai/30_automations.yaml → /_quarantine/20260120_cleanup/www_orphans/30_automations.yaml
- lovelace/5_pm_plancia.yaml → /_quarantine/20260120_cleanup/lovelace_orphans/5_pm_plancia.yaml
- lovelace/6_surplus_plancia.yaml → /_quarantine/20260120_cleanup/lovelace_orphans/6_surplus_plancia.yaml
- lovelace/cards/ehw_mini_card.yaml → /_quarantine/20260120_cleanup/lovelace_orphans/ehw_mini_card.yaml

Motivi:
- orphan_backups: backup non referenziati.
- www_orphans: yaml in www non inclusi tramite !include.
- lovelace_orphans: lovelace non in dashboard list (o commentate).

Rollback (comandi):
- orphan_backups (Bash): mv /_quarantine/20260120_cleanup/orphan_backups/configuration.yaml.bak-20251228-0849 configuration.yaml.bak-20251228-0849
- orphan_backups (Bash): mv /_quarantine/20260120_cleanup/orphan_backups/mirai.bak-20251228-0849 mirai.bak-20251228-0849
- orphan_backups (PowerShell): Move-Item /_quarantine/20260120_cleanup/orphan_backups/configuration.yaml.bak-20251228-0849 configuration.yaml.bak-20251228-0849
- orphan_backups (PowerShell): Move-Item /_quarantine/20260120_cleanup/orphan_backups/mirai.bak-20251228-0849 mirai.bak-20251228-0849
- www_orphans (Bash): mv /_quarantine/20260120_cleanup/www_orphans/*.yaml www/mirai/
- www_orphans (PowerShell): Move-Item /_quarantine/20260120_cleanup/www_orphans/*.yaml www/mirai/
- lovelace_orphans (Bash): mv /_quarantine/20260120_cleanup/lovelace_orphans/5_pm_plancia.yaml lovelace/5_pm_plancia.yaml
- lovelace_orphans (Bash): mv /_quarantine/20260120_cleanup/lovelace_orphans/6_surplus_plancia.yaml lovelace/6_surplus_plancia.yaml
- lovelace_orphans (Bash): mv /_quarantine/20260120_cleanup/lovelace_orphans/ehw_mini_card.yaml lovelace/cards/ehw_mini_card.yaml
- lovelace_orphans (PowerShell): Move-Item /_quarantine/20260120_cleanup/lovelace_orphans/5_pm_plancia.yaml lovelace/5_pm_plancia.yaml
- lovelace_orphans (PowerShell): Move-Item /_quarantine/20260120_cleanup/lovelace_orphans/6_surplus_plancia.yaml lovelace/6_surplus_plancia.yaml
- lovelace_orphans (PowerShell): Move-Item /_quarantine/20260120_cleanup/lovelace_orphans/ehw_mini_card.yaml lovelace/cards/ehw_mini_card.yaml

---

## Step 3 — Consolidamento MIRAI (2026-01-20)

Stato: Mirai consolidato in packages/* (mirai_core.yaml, mirai_modbus.yaml, mirai_templates.yaml).
Nota: mirai/*.yaml deprecato e messo in quarantine (sorgenti legacy non più incluse).

Spostato:
- mirai/00_input_boolean.yaml → /_quarantine/20260120_cleanup/legacy_mirai_sources/00_input_boolean.yaml
- mirai/01_shell_command.yaml → /_quarantine/20260120_cleanup/legacy_mirai_sources/01_shell_command.yaml
- mirai/10_modbus.yaml → /_quarantine/20260120_cleanup/legacy_mirai_sources/10_modbus.yaml
- mirai/20_templates_bits.yaml → /_quarantine/20260120_cleanup/legacy_mirai_sources/20_templates_bits.yaml
- mirai/21_main_signals.yaml → /_quarantine/20260120_cleanup/legacy_mirai_sources/21_main_signals.yaml
- mirai/21_state.yaml → /_quarantine/20260120_cleanup/legacy_mirai_sources/21_state.yaml
- mirai/22_state.yaml → /_quarantine/20260120_cleanup/legacy_mirai_sources/22_state.yaml
- mirai/23_fault.yaml → /_quarantine/20260120_cleanup/legacy_mirai_sources/23_fault.yaml
- mirai/30_automations.yaml → /_quarantine/20260120_cleanup/legacy_mirai_sources/30_automations.yaml

Rollback (comandi):
- legacy_mirai_sources (Bash): mv /_quarantine/20260120_cleanup/legacy_mirai_sources/*.yaml mirai/
- legacy_mirai_sources (PowerShell): Move-Item /_quarantine/20260120_cleanup/legacy_mirai_sources/*.yaml mirai/
