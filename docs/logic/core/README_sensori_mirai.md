# README sensori MIRAI (Modbus)

Single source of truth per la mappa registri MIRAI usata in Home Assistant.

## Hub Modbus

- Hub: `mirai`
- File: `packages/mirai_modbus.yaml`
- Protocollo: Modbus TCP
- Slave: `1`
- Host: `!secret mirai_modbus_host`
- Porta: `502`

## Mappa registri attiva

| Entity ID | Registro | Tipo | Scala | Unita | Scan |
|---|---:|---|---:|---|---:|
| `sensor.mirai_status_word_raw` | 9050 | `uint16` | 1 | - | 120s |
| `sensor.mirai_l261_compressor_step` | 9058 | `uint16` | 1 | - | 120s |
| `sensor.mirai_fault_code_raw` | 9086 | `uint16` | 1 | - | 120s |
| `sensor.mirai_status_code_raw` | 9087 | `uint16` | 1 | - | 120s |
| `sensor.mirai_l243_internal_circulator` | 9068 | `uint16` | 1 | - | 120s |
| `sensor.mirai_l241_antifreeze_lvl1` | 9078 | `uint16` | 1 | - | 180s |
| `sensor.mirai_l242_antifreeze_lvl2` | 9079 | `uint16` | 1 | - | 180s |
| `sensor.mirai_l163_outdoor_air_temp` | 8986 | `int16` | 0.1 | degC | 120s |
| `sensor.mirai_l162_outlet_water_temp` | 8987 | `int16` | 0.1 | degC | 120s |
| `sensor.mirai_l161_inlet_water_temp` | 8988 | `int16` | 0.1 | degC | 120s |

## Note operative

- Mapping ricostruito da backup runtime (`_ha_runtime_backups`) e allineato alle entita gia presenti nel registry.
- Se il device risponde ma i valori sono incoerenti, verificare offset addressing (0-based vs 1-based) con test guidati.
- Stato macchina fallback da consumi rimane in `packages/mirai_templates.yaml` come resilienza quando Modbus non risponde.
