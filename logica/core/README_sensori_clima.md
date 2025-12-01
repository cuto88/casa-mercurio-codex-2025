# Mappa sensori clima/VMC
Documentazione unica dei sensori fisici, alias canonici e KPI usati dai moduli clima (ventilazione, heating, AC).

### 1. Sensori fisici ambientali (T/UR/esterno)
| Ruolo | Entity ID CANONICO |
| --- | --- |
| T interna zona giorno | **sensor.t_in_giorno** |
| T interna zona notte 1 | **sensor.t_in_notte1** |
| T interna zona notte 2 | **sensor.t_in_notte2** |
| T interna bagno | **sensor.t_in_bagno** |
| T esterna | **sensor.t_out** |
| UR interna zona giorno | **sensor.ur_in_giorno** |
| UR interna zona notte 1 | **sensor.ur_in_notte1** |
| UR interna zona notte 2 | **sensor.ur_in_notte2** |
| UR interna bagno | **sensor.ur_in_bagno** |
| UR esterna | **sensor.ur_out** |

### 2. KPI derivati (medie, minimi, AH, delta)
- **sensor.t_in_media** — media temperatura interna; fallback `input_number.vent_backup_t_in` se tutti i sensori sono indisponibili.
- **sensor.ur_in_media** — media UR interna; fallback `input_number.vent_backup_ur_in` se tutti i sensori sono indisponibili.
- **sensor.ur_in_min** — UR interna minima fra i sensori canonici.
- **sensor.ah_in** / **sensor.ah_out** — umidità assoluta interna/esterna calcolata da T/UR.
- **sensor.delta_t_in_out** / **sensor.delta_ah_in_out** — differenze in/out usate per free-cooling, consigli finestre e hook AC.

### 3. Helper logici (input_boolean / input_number / input_select / input_datetime)
**Ventilazione/VMC**
- Modalità: `input_select.vmc_mode`, `input_select.vmc_manual_speed`, `input_boolean.vmc_manual`, `input_boolean.vmc_boost_bagno`.
- Soglie ΔT/ΔAH/UR: `input_number.vmc_freecooling_delta`, `input_number.vmc_freecooling_delta_ah`, `input_number.vent_deltat_min`, `input_number.vent_deltaah_min`, `input_number.vmc_anti_secco_ur_min`, `input_number.vmc_bagno_on`, `input_number.vmc_bagno_off`.
- Backup sensori: `input_number.vent_backup_t_in`, `input_number.vent_backup_ur_in`.
- Override: `input_boolean.vent_override_estate`.
- Fasce night-flush: `input_datetime.vent_night_flush_start`, `input_datetime.vent_night_flush_end`.
- Messaggi: `input_text.vent_messaggio_consiglio`.
- Timer: `timer.vmc_manual_timeout`.

**Heating**
- Abilitazioni stanze e logica: `input_boolean.heating_use_giorno`, `input_boolean.heating_use_notte1`, `input_boolean.heating_use_notte2`, `input_boolean.heating_use_bagno`, `input_boolean.heating_enable`, `input_boolean.heating_manual_active`.
- Modalità manuale: `input_select.heating_manual_mode`, `timer.heating_manual_timeout`.
- Setpoint e isteresi: `input_number.temp_target_risc`, `input_number.heating_setpoint_night`, `input_number.heating_hysteresis`, `input_number.heating_antifreeze_threshold`, `input_number.heating_ext_cold_threshold`, `input_number.heating_boost_delta`.
- Lock e diagnostica: `input_number.heating_min_on_minutes`, `input_number.heating_min_off_minutes`, `input_number.heating_hours_on_daily`.
- Fasce orarie: `input_datetime.heating_window_start`, `input_datetime.heating_window_end`.

**AC**
- Modalità manuale/blocco: `input_boolean.ac_manual`, `input_select.ac_manual_mode`, `timer.ac_manual_timeout`, `input_boolean.ac_block_vmc`, `timer.ac_block_vmc_timeout`.
- Setpoint e lock canonici: `input_number.ac_cool_setpoint`, `input_number.ac_dry_ur_on`, `input_number.ac_dry_ur_off`, `input_number.ac_min_on_minutes`, `input_number.ac_min_off_minutes`.

### 4. Sensori diagnostici clima/VMC
- **Ventilazione/VMC**: `binary_sensor.vmc_sensori_critici_ok`, `binary_sensor.vmc_anti_secco`, `binary_sensor.vmc_bagno_boost_auto`, `binary_sensor.vmc_freecooling_candidate`, `binary_sensor.vmc_freecooling_attivo`, `sensor.vmc_vel_target`, `sensor.vmc_vel_index`, `sensor.ventilation_priority`, `sensor.ventilation_reason`, `sensor.vmc_freecooling_status`, `sensor.clima_open_windows_recommended`, `sensor.vent_stagione`.
- **Heating**: `sensor.heating_reason` (priority/azione), `sensor.heating_priority` (estratto da reason), `binary_sensor.heating_failsafe_sensors_bad`, `sensor.heating_t_in_min`, `sensor.heating_rooms_below_target`, `binary_sensor.heating_lock_min_on_ok`, `binary_sensor.heating_lock_min_off_ok`, `binary_sensor.heating_finestra_oraria`, `binary_sensor.heating_esterna_fredda`, `binary_sensor.heating_almeno_una_stanza_sotto_target`, `sensor.heating_minutes_since_change`, `sensor.heating_hours_on_today`, `sensor.heating_hours_on_yesterday`.
- **AC**: `binary_sensor.ac_failsafe_sensors_bad`, `binary_sensor.ac_block_by_vmc`, `binary_sensor.ac_lock_min_on_ok`, `binary_sensor.ac_lock_min_off_ok`, `sensor.ac_priority`, `sensor.ac_reason`, `binary_sensor.stagione_calda` (vincolo stagionale per AC/ventilazione).

### Heating — diagnostica opzionale
- `sensor.heating_rooms_active` — numero stanze effettivamente attive.
- `sensor.heating_error_zona_giorno` — errori/criticità zona giorno.
- `sensor.heating_error_zona_notte` — errori/criticità zona notte.
- `binary_sensor.heating_window_pv` — blocco heating per finestre aperte in fascia FV.
- `binary_sensor.heating_window_night` — blocco heating per finestre aperte in fascia notturna.
- `binary_sensor.heating_should_run` — decisione finale ON/OFF della logica heating.

### AC — diagnostica e runtime opzionale
- `sensor.ac_giorno_tempo_on_oggi`
- `sensor.ac_giorno_cicli_on_oggi`
- `sensor.ac_notte_tempo_on_oggi`
- `sensor.ac_notte_cicli_on_oggi`
- `sensor.ac_giorno_ultimo_on`, `sensor.ac_giorno_ultimo_off`
- `sensor.ac_notte_ultimo_on`, `sensor.ac_notte_ultimo_off`

Questi sensori sono opzionali (grafici/diagnostica) e non fanno parte della logica core.

### 5. Attuatori e stati finestre
- **VMC**: `switch.vmc_vel_0`, `switch.vmc_vel_1`, `switch.vmc_vel_2`, `switch.vmc_vel_3` (attuazione velocità); `timer.vmc_*` come lock runtime.
- **Heating**: `switch.heating_master` (alias invertito di `switch.4_ch_interrutore_3`), `switch.heating_night_block` (alias blocco), `switch.4_ch_interrutore_3` hardware.
- **AC**: `switch.ac_giorno`, `switch.ac_notte` (split giorno/notte pilotati da logica AC).
- **Finestre**: `binary_sensor.windows_all_closed` (canonico aggregato), `binary_sensor.windows_giorno_any`, `binary_sensor.windows_notte_any`, `binary_sensor.windows_bagno_any`, `sensor.windows_open_count`, `sensor.vent_finestre_state`.
