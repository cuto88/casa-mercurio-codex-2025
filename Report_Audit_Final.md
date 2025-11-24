# Report Audit Final — Stack Clima

## Sintesi esito
- Allineati i controlli ΔT/ΔAH della ventilazione naturale con le soglie dedicate (`input_number.vent_deltat_min` e `input_number.vent_deltaah_min`) per evitare conflitti con il freecooling VMC.
- Aggiornata la configurazione Lovelace per limitare le view attive al solo stack clima (1-2-3), come richiesto.

## Issue rilevate
- **Soglie ΔT/ΔAH errate**: i binary sensor `vent_deltat_ok` e `vent_deltaah_ok` utilizzavano le soglie del freecooling VMC (`vmc_freecooling_*`), generando raccomandazioni finestre incoerenti e collisioni con la logica freecooling.
- **Dashboard fuori perimetro**: in `configuration.yaml` erano attive view non richieste (consumi/energia) nel blocco `lovelace.dashboards`.

## Correzioni applicate
- Reindirizzate le soglie dei sensori `vent_deltat_ok` e `vent_deltaah_ok` agli slider dedicati alla ventilazione naturale (`vent_deltat_min`, `vent_deltaah_min`) e corretta l'availability di conseguenza.
- Pulito il blocco `lovelace.dashboards` mantenendo soltanto le view clima (1 Ventilazione, 2 Riscaldamento, 3 Clima) con nota esplicita sulle view attive.

## Indicazioni per l'utente
- Verificare che gli slider "Ventilazione — ΔT minimo" e "Ventilazione — ΔAH minimo" siano valorizzati: ora governano sia le raccomandazioni finestre sia l'abilitazione della ventilazione naturale.
- Il menu laterale deve mostrare solo le view 1-2-3. Se servono altre plance, reintrodurle manualmente fuori dallo scope attuale.

## File toccati
- `packages/1_ventilation.yaml`
- `configuration.yaml`

## File inutili da eliminare
- Nessuno individuato nello scope analizzato.
