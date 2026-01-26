###############################################################################
# Heating — Documentazione layout plancia HEATING
# Riferimento per lovelace/2_heating_plancia.yaml (impianto a pavimento).
###############################################################################

COLONNA 1 — STATO & COMANDI
- Glance "Stato logiche": `binary_sensor.heating_should_run`, `binary_sensor.heating_finestra_oraria`, `binary_sensor.heating_esterna_fredda`, `binary_sensor.heating_almeno_una_stanza_sotto_target`, lock ON/OFF.
- Markdown "Come decide" (sintesi) — evidenzia P0_failsafe, P1_anti_frost, P2_comfort, P3_pv_boost, P4_night_setback, manual/idle.
- Pulsanti button/tile: abilitazione impianto, force on/off, pacchetto manuale con `input_boolean.heating_manual_active`, `input_select.heating_manual_mode` e timer.
- Tile finale su `switch.4_ch_interrutore_3` per interruttore generale fisico.

COLONNA 2 — KPI & SELEZIONE STANZE
- Tile con grafico per `sensor.t_in_med`, `sensor.t_in_min`, `sensor.t_out`, `input_number.temp_target_risc` e `sensor.heating_minuti_da_ultimo_cambio`.
- Entities "Stanze incluse" con toggle `input_boolean.heating_use_*` + riepilogo `sensor.heating_stanze_attive`.

COLONNA 3 — TREND, STATISTICHE & SOGLIE
- History-graph 24h su temperature stanza/esterna (inclusa `sensor.t_in_med`) e decisioni logiche (should_run, finestra, esterna fredda, sotto target, lock min on/off).
- Statistics-graph 7gg temperature (mean/min/max) e 30gg ore ON (`input_number.heating_hours_on_daily`).
- Entities "Soglie & Lock" per input_datetime finestra, target, tolleranza, soglie esterne e timer min_on/min_off.

COLONNA 4 — DIAGNOSTICA
- Entity-filter per evidenziare stati `unknown/unavailable` su sensori base e attuatori.
- Sezione dedicata nel file per espandere facilmente altri controlli.

NOTE
- Tutti gli entity_id provengono da `packages/2_heating.yaml` e 0_sensors.yaml.
- Pulsanti manuali rispettano la logica di override documentata in `docs/logic/heating/README.md`.
- Layout mobile-first (sections) coerente con regole plancia core.

COME DECIDE (SINTESI)
- Gestisce il pavimento per portare le zone al target rispettando la finestra 10–16 e i lock min_on/min_off.
- Può anticipare la partenza se c’è surplus PV (pre-carica), altrimenti limita le accensioni.
- Antifreeze e comfort critico possono derogare la finestra oraria.

RIFERIMENTI LOGICI
- Logiche condivise: vedi `docs/logic/core/regole_core_logiche.md`.
- Linee guida UI generali: vedi `docs/logic/core/regole_plancia.md`.
- Logica specifica modulo: vedi `docs/logic/heating/README.md`.
- Priorità ufficiali: `README_ClimaSystem.md` sezione Heating.
