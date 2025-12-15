# MIRAI Modbus package (router)

Questa cartella contiene la logica del pacchetto MIRAI suddivisa in file modulari,
caricati tramite `packages/mirai.yaml` come router leggero:

```yaml
input_boolean: !include mirai/00_input_boolean.yaml
shell_command: !include mirai/01_shell_command.yaml
modbus: !include mirai/10_modbus.yaml
template: !include mirai/20_templates.yaml
automation: !include mirai/30_automations.yaml
```

- `00_input_boolean.yaml`: entità condivise per controllare l'autodiscovery Modbus.
- `01_shell_command.yaml`: comandi shell per creare la cartella log e scrivere il CSV di debug.
- `10_modbus.yaml`: integrazione Modbus e sensori correlati.
- `20_templates.yaml`: sensori template e binary sensor per diagnostica/autodiscovery.
- `30_automations.yaml`: automazioni e notifiche di debug.
