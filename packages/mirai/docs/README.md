# MIRAI Modbus package (router)

Questa cartella contiene la logica del pacchetto MIRAI suddivisa in file modulari,
caricati tramite `packages/mirai.yaml` come router leggero:

```yaml
<<: !include mirai/00_globals.yaml
modbus: !include mirai/10_modbus.yaml
template: !include mirai/20_templates.yaml
automation: !include mirai/30_automations.yaml
```

- `00_globals.yaml`: entità condivise (input_boolean, shell_command, notify) per le automazioni MIRAI.
- `10_modbus.yaml`: integrazione Modbus e sensori correlati.
- `20_templates.yaml`: sensori template e binary sensor per diagnostica/autodiscovery.
- `30_automations.yaml`: automazioni e notifiche di debug.
