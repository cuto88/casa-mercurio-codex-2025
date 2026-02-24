# STEP4 Restart Hardening (Runtime)
Date: 2026-02-24
Target: ridurre i rallentamenti di restart/shutdown su Home Assistant runtime.

## Contesto runtime
- Host runtime: `root@192.168.178.84:2222`
- Core version verificata: `2026.2.3`
- Config path attivo: `/homeassistant`

## Interventi applicati
1. Fix errori startup non bloccanti ma rumorosi:
- `packages/climateops/core/kpi.yaml`
  - Disabilitato contenuto `history_stats` YAML non supportato su HA 2026.2.x.
- `packages/climate_bootstrap_cutover_temp.yaml`
  - Sostituito `enabled: false` con `initial_state: false` per compatibilita` schema automation.
- Template numerici hardening:
  - rimozione ritorni stringa `unknown` in sensori numerici principali (fallback a `none`/non disponibile).

2. Hardening polling Modbus MIRAI:
- File: `packages/mirai_modbus.yaml`
- Riduzione drastica superficie:
  - mantenuti solo 2 registri essenziali (`9050`, `9058`)
  - `scan_interval` portato a `120s`
  - `retries: 0`
  - `timeout: 1`, `retry_on_empty: false`

3. Hardening template EHW raw (update serale):
- File: `packages/ehw_modbus.yaml`
- Sensori template aggiornati:
  - `ehw_t01_raw` .. `ehw_t06_raw`
  - `ehw_setpoint_raw_a`, `ehw_setpoint_raw_b`
- Modifica: output solo numerico o `none` (eliminati ritorni stringa non numerica tipo `unavailable`).

## Verifiche eseguite
- `ha core check`: `Command completed successfully`
- `ha core restart`: completato
- Verifica stato core post restart: `boot: true`
- Ping/porta Modbus dal runtime:
  - `192.168.178.190` raggiungibile via ICMP
  - `192.168.178.190:502` risulta open
- Deploy update EHW:
  - sync su `/homeassistant/packages/ehw_modbus.yaml`
  - `ha core check` OK
  - `ha core restart` completato

## Esito
- Ridotti i timeout Modbus rispetto al profilo precedente (meno registri, meno frequenza).
- Persistono timeout applicativi Modbus su registri `9050/9058` (device/protocol-level), non rete IP.
- Restart e check runtime risultano stabili; residua da chiudere la causa protocollo lato Mirai.
- Commit/push associato update EHW:
  - commit: `2aebc49`
  - branch: `main`
  - remote: `origin/main`

## Prossimo passo consigliato
- Verifica mappa registri/slave effettivo dispositivo Mirai (oppure disattivazione temporanea totale `mirai_modbus` fino a conferma protocollo).
- Pulizia warning meteo duplicato (`weather.forecast_casa`) in configurazione UI (`.storage`), non emerso da YAML repo.
