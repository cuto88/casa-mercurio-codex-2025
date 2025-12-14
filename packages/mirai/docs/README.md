# MIRAI Modbus package (source)

Questa cartella contiene i sorgenti logici della soluzione "aggregatore" per Home Assistant.
Il file effettivamente letto da HA è `packages/mirai.yaml`, generato aggregando manualmente
questi blocchi:

- `modbus/mirai_modbus_core.yaml`: sensori Modbus validati (stato, bitmask, temperatura esterna, energia).
- `modbus/mirai_modbus_autodiscovery.yaml`: input boolean di abilitazione e registri candidati.
- `templates/mirai_autodiscovery_templates.yaml`: selezione e punteggi dei candidati, più template di debug.

I file in questa struttura non vengono inclusi direttamente da Home Assistant.
Apporta le modifiche qui e poi aggiorna `packages/mirai.yaml` per renderle attive.
