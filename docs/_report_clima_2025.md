# Audit Clima 2025 — VMC / Heating / AC / Ventilazione naturale

## Sezione 1 — Mappa moduli
- **1_ventilation.yaml (VMC + ventilazione naturale / consigli finestre)**
  - Priorità VMC: failsafe, boost bagno, anti-secco, freecooling, manuale.
  - KPI condivisi: ΔT (`sensor.delta_t_in_out`), ΔAH (`sensor.delta_ah_in_out`), stagionalità (`binary_sensor.stagione_calda`/`stagione_fredda`), meteo (pioggia/vento/PM2.5) e counter finestre.
  - Consigli finestre: `binary_sensor.vent_recommend_open`/`vent_recommend_close`, `binary_sensor.vent_condizioni_meteo_ok`, `binary_sensor.vent_condizioni_termiche_ok`.
  - Hook/eventi: `hook_vmc_request_ac_block`, `hook_vent_enable_night_flush`, integrazione con priorità `sensor.ventilation_priority`.

- **2_heating.yaml (Riscaldamento)**
  - Priorità: P0_failsafe, P1_anti_frost, P2_comfort, P3_pv_boost, P4_night_setback.
  - Entità di stato: `sensor.heating_reason`, `sensor.heating_priority`, `binary_sensor.heating_failsafe_sensors_bad`.

- **3_ac.yaml (Climatizzazione estiva)**
  - Priorità: P0_failsafe, P1_block_vmc, P2_dry, P3_cool, idle.
  - Entità di stato: `sensor.ac_reason`, `sensor.ac_priority`, `binary_sensor.ac_failsafe_sensors_bad`, `binary_sensor.ac_block_by_vmc`.

- **1_ventilation_windows.yaml (monitor finestre)**
  - Solo monitoraggio contatti/manuali (`input_boolean.vent_*`), gruppi zona giorno/notte/bagni e KPI `sensor.windows_open_count` / `binary_sensor.windows_all_closed`.

## Sezione 2 — Plance Lovelace
- **1_ventilation_plancia.yaml**
  - Vista unica per VMC + consigli finestre: priorità, freecooling, KPI ΔT/ΔAH, meteo e suggerimenti apertura.
- **1_ventilation_windows.yaml**
  - Monitor dedicato aperture finestre con gruppi per zona e storico aperture.
- **2_heating_plancia.yaml**
  - Allineata con gli helper heating attivi.
- **3_ac_plancia.yaml**
  - Allineata con gli helper AC e blocchi VMC.
- (Deprecate) `1_vent_plancia.yaml` e `2_vmc_plancia.yaml` rimandano alla nuova vista unificata.

## Sezione 3 — VMC Free-cooling vs Consigli Finestre

| Free-cooling VMC | Ventilazione naturale / Apri finestre |
| --- | --- |
| **KPI usati:** `sensor.t_in_media`, `sensor.t_out`, `sensor.ah_in`, `sensor.ah_out`, ΔT/ΔAH soglie `input_number.vmc_freecooling_delta`/`_delta_ah`, stagionalità, timer max-run/cooldown, AC spenta. | **KPI usati:** `sensor.delta_t_in_out`, `sensor.delta_ah_in_out`, stesse soglie ΔT/ΔAH degli input_number, meteo (`binary_sensor.vent_pioggia`, `vent_vento_blocco`, `vent_air_quality_ok`), `binary_sensor.stagione_calda`. |
| **Condizione ON:** stagione calda, AC Giorno/Notte off, failsafe off, Tin ≥ `vmc_fc_ph_tin_on`, Tout ≤ Tin − ΔT, AHout ≤ AHin − ΔAH, nessun cooldown attivo. | **Condizione OPEN:** stagione calda/override, nessun blocco meteo, ΔT e ΔAH sopra soglia. |
| **Hold/lock:** mantiene con isteresi finché timer max-run attivo, poi cooldown; invia `hook_vmc_request_ac_block` e `hook_vent_enable_night_flush`. | **Hold/lock:** nessun lock, valutazione continua; la priorità globale `sensor.ventilation_priority` evita conflitti con freecooling (P2 > P3). |

## Sezione 4 — Incongruenze e TODO consigliati
- Moduli legacy 1_vent / 2_vmc / 1_ventilation_* deprecati e sostituiti da `1_ventilation.yaml`.
- Plance legacy sostituite con `1_ventilation_plancia.yaml` e `1_ventilation_windows.yaml`; nessuna entità mancante rilevata.
- TODO leggero: valutare in futuro l’uso di sensori contatto reali al posto degli `input_boolean.vent_*` per le finestre.
