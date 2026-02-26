# STEP8 Runtime Audit 24h (2026-02-26)

Date: 2026-02-26  
Scope: audit runtime ultime 24 ore (finestra osservata da 2026-02-25 22:14 CET a 2026-02-26 18:01 CET circa).

## Contesto runtime (FACT)
- Host: `core-ssh` (`root`)
- Ora host al momento audit: `2026-02-26T17:24:37+01:00`
- Config path rilevato: `/homeassistant`
- Core info:
  - `version: 2026.2.3`
  - `boot: true`
  - `watchdog: true`
- Config check:
  - `ha core check` -> `Command completed successfully.`

## Evidenza trace (FACT)
Fonte: `/homeassistant/.storage/trace.saved_traces`

- Timestamp file trace: `2026-02-25 22:14:47 +0100`
- Presenza trace `automation.climateops_system_actuate`: SI
- Presenza azioni script:
  - `script.ac_giorno_apply`: SI
  - `script.ac_notte_apply`: SI
- Occorrenze testuali nel file (indicative, non equivalenti 1:1 a run distinti):
  - `climateops_system_actuate`: `36`
  - `script.ac_giorno_apply`: `7`
  - `script.ac_notte_apply`: `7`
- Esempio context automation estratto:
  - `context.id = 01KJBADKVM205N65TSXJ8JV2S4`
  - `item_id = climateops_system_actuate`
  - trigger `time pattern`
  - start `2026-02-25T21:14:00.436677+00:00`
  - finish `2026-02-25T21:14:02.029252+00:00`

## Evidenza stato snapshot (FACT)
Fonte: `/homeassistant/.storage/core.restore_state`

- Timestamp file snapshot: `2026-02-26 18:01:03 +0100`
- Entita` trovate con stato recente:
  - `switch.heating_master = off` (last_changed `2026-02-26T16:31:01.275909+00:00`)
  - `sensor.vmc_vel_target = 1` (last_changed `2026-02-26T06:30:36.926382+00:00`)
- Nota: `switch.ac_giorno`/`switch.ac_notte` non risultano nel frammento `core.restore_state` interrogato durante questo audit.

## Evidenza log core (FACT)
Fonte: `ha core logs --lines 1200`

- Conteggio pattern:
  - `State TIME:` -> `85`
  - `Traceback` -> `0`
  - `ERROR (MainThread) [homeassistant.core]` -> `0` (su pattern esatto usato)
- Righe evidenziate durante il campionamento:
  - molte entry `ERROR [homeassistant.core] State TIME: ...` con cadenza regolare
  - nessun traceback nel campione analizzato

## Esito audit 24h
- Writer chain ClimateOps/AC: **evidenza presente** (automation + script AC in trace).
- Config/runtime core: **OK** (`ha core check` passato, core boot up).
- Anomalia da attenzionare: **spam log `State TIME`** ricorrente (non bloccante in questo audit, ma da investigare).

## Limiti osservati
1. CLI disponibile su host non espone `ha state get`, quindi stato live entita` ricavato via snapshot `.storage`.
2. Correlazione completa `context_id` tra automation -> script -> switch non chiusa al 100% con grep/sed da shell (struttura trace complessa).
3. `sqlite3` non disponibile su host, quindi niente query diretta su recorder DB in questo passaggio.

## Azioni consigliate (next)
1. Export UI trace per `automation.climateops_system_actuate` e `script.ac_giorno_apply`/`script.ac_notte_apply` e salvataggio in `docs/runtime_evidence/2026-02-26/`.
2. Chiusura correlazione `context_id` evento-level (automation/script/switch) su evidenza UI export.
3. Analisi sorgente log `State TIME` (ricerca automazione/script che invia `logger` con livello error).
