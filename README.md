# Casa Mercurio Codex 2025
Configurazione Home Assistant modulare per la casa Mercurio.
Struttura base: packages/, docs/logic/, mirai/, lovelace/.
packages/ contiene automazioni e logica per domini HA.
docs/logic/ raccoglie automazioni e script orchestrati ad alto livello.
mirai/ ospita runtime e asset personalizzati del progetto Mirai.
lovelace/ conserva le dashboard YAML; docs/ e tools/ restano solo locali.
ops/ include gli script di manutenzione: usa ops/synch_ha.ps1 per sincronizzare verso Z:\config.
Lo script copia solo packages, mirai, docs/logic e lovelace in modalità mirror con esclusioni temporanee.
Per dettagli tecnici e note climatizzazione leggi README_ClimaSystem.md.

## Quality gates (ops)
Per eseguire i controlli locali:
- `powershell -NoProfile -ExecutionPolicy Bypass -File ops\run_gates.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File ops\deploy_safe.ps1`

Per evitare falsi positivi e cartelle di backup/quarantena, il lint YAML gira solo sui file tracciati da Git.

## MIRAI package structure
packages/mirai.yaml deve restare una mappa di integrazioni al root, senza wrapper `mirai:`.
mirai/20_templates.yaml deve essere una lista (inizia con `- binary_sensor:`), non una mappa.
mirai/30_automations.yaml deve essere una lista (inizia con `- id:` o `- alias:`).
I file mirai/00_input_boolean.yaml e mirai/01_shell_command.yaml devono restare mappe.
mirai/10_modbus.yaml deve essere una lista di hub Modbus, senza root `modbus:`.

## Notifiche Telegram
Nel package `packages/notify_telegram.yaml` è definita la notifica `notify.telegram_davide`
per inviare messaggi alla chat principale senza hardcodare l'ID del bot nelle automazioni.
