# Plancia Consumi Mirai+EHW

File dashboard: `lovelace/consumi_mirai_ehw_plancia.yaml`

## Entita usate (runtime LocalTuya `01K0AE579DTMM0ZED250CYNCT8`)

- Pinza Mirai (A)
  - `sensor.sensor_grid_power_w` (potenza istantanea W)
  - `sensor.a_energia_prelevata_forward` (kWh cumulati)
  - `sensor.a_energia_immessa_reverse` (kWh cumulati)
- Pinza EHW (B)
  - `sensor.sensor_pv_power_w` (potenza istantanea W)
  - `sensor.b_energia_prelevata_forward` (kWh cumulati)
  - `sensor.b_energia_immessa_reverse` (kWh cumulati)
- Direzione:
  - `sensor.sensor_grid_direction`

## Layout

- Stato attuale: potenze istantanee e direzione flusso.
- Contatori cumulati: blocchi separati Mirai/EHW.
- Andamento 24h: history potenze.
- Consumi giornalieri 7 giorni: `statistics-graph` (stat `change`) su kWh prelevati.

## Note operative

- Mapping verificato su runtime il `2026-02-23` via `core.entity_registry`.
- Se in campo le pinze risultano invertite, scambiare solo le 2 entita di potenza
  (`sensor.sensor_grid_power_w` <-> `sensor.sensor_pv_power_w`) e i blocchi A/B.
