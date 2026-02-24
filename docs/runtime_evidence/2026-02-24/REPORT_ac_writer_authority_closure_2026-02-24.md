# AC Writer Authority — Closure Report (2026-02-24)

Obiettivo:
- Rendere `ClimateOps` writer unico effettivo per AC (`switch.ac_giorno`, `switch.ac_notte`) durante cutover AC.

Implementazione applicata:
- Commit: `0ee8700`
- File: `packages/climateops/actuators/system_actuator.yaml`
- Nuova automazione: `automation.climateops_enforce_ac_writer_authority`
- Validazione config: `ha core check` OK.

Stato cutover:
- `input_boolean.climateops_cutover_ac`: ON (confermato da UI operativa utente).

Evidenza funzionale finale (live test utente):
- Azione test: forzato `ON` su `switch.ac_giorno` e `switch.ac_notte`.
- Esito osservato: entrambi tornano immediatamente su `OFF`.
- Interpretazione: i writer esterni non mantengono il comando; la governance effettiva resta a ClimateOps.

Conclusione:
- Obiettivo raggiunto operativamente: writer unico AC effettivo = ClimateOps.
- Stato: CHIUSO.

Note:
- Alcune fonti storage (`core.restore_state`/dump DB caldo) possono risultare temporaneamente stale o non consistenti al secondo; la prova live ON->OFF rimane l'evidenza finale determinante.
