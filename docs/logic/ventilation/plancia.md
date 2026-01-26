# Ventilation — Plancia

Obiettivo: descrivere struttura e contenuti di `lovelace/1_ventilation_plancia.yaml` per ventilazione naturale + VMC come unico modulo.

COLONNA 1 — STATO & KPI
- Entities "Stato generale": `sensor.ventilation_priority`, `sensor.ventilation_reason`, `binary_sensor.vmc_sensors_ok`.
- Entities "KPI aria": `sensor.t_in_med`, `sensor.ur_in_media`, `sensor.delta_t_in_out`, `sensor.delta_ah_in_out`.

COLONNA 2 — COMANDI & VELOCITÀ
- Entities "Controlli manuali": `input_select.vmc_mode`, `input_boolean.vmc_manual`, `input_select.vmc_manual_speed`, `input_boolean.vmc_boost_bagno`.
- Entities "Velocità reali": `sensor.vmc_vel_target`, `sensor.vmc_vel_index`, `switch.vmc_vel_0/1/2/3`.

COLONNA 3 — CONDIZIONI & MESSAGGI
- Entities "Freecooling": `binary_sensor.vmc_freecooling_candidate`, `binary_sensor.vmc_freecooling_active`, `sensor.vmc_freecooling_status`.
- Entities "Finestre": `binary_sensor.windows_all_closed`, `sensor.clima_open_windows_recommended`.
- Entities "Messaggi": `input_text.vent_messaggio_consiglio`.

NOTE
- Nessuna definizione di entità nella plancia: tutti gli entity_id sono canonici (`packages/1_ventilation.yaml` + sensori base).
- Layout mobile-first (sections) coerente con regole plancia core.

RIFERIMENTI LOGICI
- Logica ventilazione naturale, night-flush e VMC: `docs/logic/ventilation/README.md`.
- Linee guida UI generali: `docs/logic/core/regole_plancia.md`.

> Revisione documentazione clima Vent – allineata a implementazione attuale.
