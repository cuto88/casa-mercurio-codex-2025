# Audit Clima 2025 — VMC / Heating / AC / Ventilazione naturale

## Sezione 1 — Mappa moduli
- **1_vent.yaml (ventilazione naturale / consigli finestre)**
  - Condizioni principali: flag stagione estiva (`binary_sensor.vent_flag_estate`), controlli meteo (pioggia, vento, PM2.5), KPI di differenza (`sensor.delta_t_in_out`, `sensor.delta_ah_in_out`).
  - Entità chiave: `binary_sensor.vent_recommend_open`, `binary_sensor.vent_recommend_close`, `binary_sensor.vent_condizioni_meteo_ok`, `binary_sensor.vent_condizioni_termiche_ok`.
  - Hook/eventi: riceve evento `hook_vent_enable_night_flush` dalla VMC per allineare il night flush.

- **2_vmc.yaml (VMC)**
  - Priorità: P0_failsafe, OV (AC notte = DRY → vel_0), P1 Bagno/BOOST, P1-Lite ΔUR interno alto, P1B escalation DRY, P2 free-cooling, P3 anti-secco, P4 baseline.
  - Entità di stato: `sensor.vmc_reason`, `sensor.vmc_priority`, `sensor.vmc_freecooling_status`, `binary_sensor.vmc_failsafe_sensors_bad`.
  - Hook/eventi: `hook_vmc_request_ac_block` (blocca AC), `hook_vent_enable_night_flush` (abilita ventilazione naturale), `hook_ac_request_vmc_low` (gestito nei choose), timer `vmc_freecooling_max_run`/`vmc_freecooling_cooldown`.

- **3_heating.yaml (Riscaldamento)**
  - Priorità: P0_failsafe, P1_anti_frost, P2_comfort, P3_pv_boost, P4_night_setback.
  - Entità di stato: `sensor.heating_reason`, `sensor.heating_priority`, `binary_sensor.heating_failsafe_sensors_bad`, finestre dinamiche (`binary_sensor.heating_window_comfort`, `_pv`, `_night`).
  - Hook/eventi: nessun hook esterno; logica interna basata su fasce orarie e disponibilità surplus.

- **4_ac.yaml (Climatizzazione estiva)**
  - Priorità: P0_failsafe, P1_block_vmc, P2_dry, P3_cool, idle.
  - Entità di stato: `sensor.ac_reason`, `sensor.ac_priority`, `binary_sensor.ac_failsafe_sensors_bad`, `binary_sensor.ac_block_by_vmc`.
  - Hook/eventi: trigger su `hook_vmc_request_ac_block`/`hook_ac_request_vmc_low` integrati nelle automazioni AC e VMC; lock min_on/off per protezione cicli (`binary_sensor.ac_lock_min_on_ok`, `binary_sensor.ac_lock_min_off_ok`).

## Sezione 2 — Plance Lovelace
- **2_vmc_plancia.yaml**
  - Entità mancanti prima del fix: `input_number.vmc_freecooling_delta`, `input_number.vmc_freecooling_delta_ah` (presenti nella logica ma non definiti come helper).
  - Azioni: aggiunti gli helper in `2_vmc.yaml` per allineare plancia e logica (nessuna riga commentata).

- **3_heating_plancia.yaml**
  - Refuso: `sensor.heating_minuti_da_ultimo_cambio` non esistente → corretto in `sensor.heating_minutes_since_change`.
  - Nessuna entità commentata; tutte le altre corrispondono agli helper attivi.

- **4_ac_plancia.yaml**
  - Nessuna entità mancante rispetto a `4_ac.yaml`; tutte in linea con gli helper AC e blocchi VMC.

- **1_vent_plancia.yaml**
  - Nessuna entità mancante: tutte presenti in `1_vent.yaml` (sensori meteo, consigli, stati finestre manuali).

- Conferma: dopo i fix sopra, nessuna plancia referenzia entità inesistenti.

## Sezione 3 — VMC Free-cooling vs Consigli Finestre

| Free-cooling VMC | Ventilazione naturale / Apri finestre |
| --- | --- |
| **KPI usati:** `sensor.t_in_media`, `sensor.t_out`, `sensor.ah_in`, `sensor.ah_out`, stagionalità (`binary_sensor.stagione_calda`), lock/timer `vmc_freecooling_max_run` e `vmc_freecooling_cooldown`, controlli AC spenta. | **KPI usati:** `sensor.delta_t_in_out`, `sensor.delta_ah_in_out`, meteo (`binary_sensor.vent_pioggia`, `vent_vento_blocco`, `vent_air_quality_ok`), flag estate (`binary_sensor.vent_flag_estate`). |
| **Condizione ON:** stagione calda, AC Giorno/Notte off, failsafe off, Tin ≥ `vmc_fc_ph_tin_on` (24°C default), Tout ≤ Tin − ΔT (`vmc_freecooling_delta`), AHout ≤ AHin − ΔAH (`vmc_freecooling_delta_ah`), nessun cooldown attivo. | **Condizione OPEN:** flag estate o override, nessun blocco meteo, ΔT ≥ `vent_deltat_min` (1.5°C), ΔAH ≥ `vent_deltaah_min` (1.0 g/m³). Nessun controllo su AC o timer. |
| **Hold/lock:** mantiene se in free-cooling finché timer max-run attivo e condizioni ridotte (ΔT e ΔAH con hysteresis), poi avvia cooldown. Eventi `hook_vmc_request_ac_block` e `hook_vent_enable_night_flush` inviati. | **Hold/lock:** non presenti; consigli aggiornati in tempo reale senza cooldown. |

**Osservazioni**
- Le soglie termiche sono simili ma non identiche: il free-cooling richiede anche AH assoluta favorevole, AC spenta e timer di max-run/cooldown; il consiglio finestre usa solo differenze e meteo.
- Possibili sovrapposizioni: in estate con ΔT/ΔAH favorevoli entrambe le logiche si attivano (VMC in free-cooling e avviso “apri finestre”), ma senza conflitti espliciti perché il free-cooling già invia `hook_vent_enable_night_flush` per coordinare l’apertura.
- La plancia Ventilazione aggiunge valore come monitor delle aperture manuali e delle condizioni meteo; le KPI termiche in parte replicano quelle VMC.

## Sezione 4 — Incongruenze e TODO consigliati
- Nessun refuso aperto: tutte le entità usate dalle plance ora sono definite o corrette.
- Suggerimento: valutare unificare la valutazione di ΔT/ΔAH tra free-cooling e consigli finestre per ridurre duplicazioni e mantenere soglie coerenti.
- Possibile miglioramento plancia futura `0_clima_overview`: KPI riassuntivi di `sensor.vmc_priority`, `sensor.heating_priority`, `sensor.ac_priority`, stato failsafe (`binary_sensor.*_failsafe_sensors_bad`) e indicatori meteo `binary_sensor.vent_weather_block`/`vent_recommend_open`.
