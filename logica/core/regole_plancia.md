# Regole plancia (UI core)

Linee guida comuni per tutte le plance Lovelace. Nessuna soglia o logica numerica va riportata qui: per logiche e priorità consultare `core/regole_core_logiche.md` e i file logici dei moduli.

## Layout e struttura
- Mobile-first con `sections:` e `max_columns` per preservare l’ordine tra mobile e desktop.
- Tre blocchi fissi, nell’ordine: **Stato & Comandi rapidi**, **KPI principali**, **Trend/Lock/Diagnostica**.
- Card obbligatorie:
  - **Glance/Chip di stato**: priorità/modo corrente, lock attivi, eventuali override manuali.
  - **Comandi rapidi**: pulsanti o tile per toggle manuale, con timer di rientro ben visibile.
  - **Markdown “Come decide”**: testo breve e leggibile che rimanda a `core/regole_core_logiche.md` e al file logico del modulo.

## Palette e convenzioni grafiche
- Colori entità: rosso = esterno, giallo = zona giorno, blu = zona notte, verde = bagno, neutro (grigio/acqua/viola) = derivate/logiche.
- Tile/graph: una metrica per tile; linee senza riempimento; soglie visualizzate come linee nominate.
- Badge e icone: usare badge per lock/stato manuale; icone coerenti tra moduli (es. ventilazione ↔ `mdi:fan`, AC ↔ `mdi:air-conditioner`).

## Sezione “Come decide”
- Testo sintetico (bullet) che spiega perché il modulo è nello stato attuale.
- Deve contenere rimandi a `core/regole_core_logiche.md` e al file logico del modulo (es. `2_vmc.txt`).
- Nessun decision tree dettagliato o soglia numerica: solo il flusso logico ad alto livello.

## Debug e diagnostica
- Sezione finale opzionale con entity-filter per `unknown/unavailable` e KPI raw.
- Per le plance debug/test indicare chiaramente quando un hook forza le priorità (vedi `hook_debug_force_state`).

## Collegamenti obbligatori
- Ogni plancia deve includere una sezione **RIFERIMENTI LOGICI** con:
  - Logiche condivise → `core/regole_core_logiche.md`
  - Linee guida UI → `core/regole_plancia.md`
  - Logica specifica del modulo → `<nome_file_logico_modulo>.txt`
