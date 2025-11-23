# Report plance Lovelace — Casa Mercurio 2025

## Plance modificate
- 1_vent_plancia.yaml
- 2_vmc_plancia.yaml
- 3_heating_plancia.yaml
- 4_ac_plancia.yaml
- 5_pm_plancia.yaml
- 6_surplus_plancia.yaml
- 9_debug_sistema_plancia.yaml
- 9_test_plancia.yaml

## Entità mancanti individuate
- Nessuna entità lasciata irrisolta. Sono stati rimossi i riferimenti a `sensor.ac_mode_label`, `binary_sensor.ac_need_dry`, `binary_sensor.ac_need_cool`, `binary_sensor.ac_should_run` e `binary_sensor.heating_finestra_oraria`, non presenti nei package ufficiali. Le card ora usano le entità `sensor.ac_reason`, `sensor.ac_priority` e `binary_sensor.heating_window_comfort` dove applicabile.

## Modifiche principali
- Allineato tutte le plance al layout standard (Stato → Setpoint/Comandi → KPI → Grafici → Runtime → Debug) con massimo tre colonne e card native (entities, glance, history-graph, statistics-graph).
- Pulizia markdown superfluo e riorganizzazione dei titoli per coerenza.
- Consolidati KPI e grafici evitando duplicazioni di card o informazioni ridondanti.
- Aggiornate le sezioni di debug per mostrare solo entità effettivamente presenti nei package 1_vent, 2_vmc, 3_heating e 4_ac.

## Entità duplicate rimosse
- Eliminati grafici e KPI duplicati nelle plance PM, Surplus e Debug; rimossi i duplicati di timer VMC dalle sezioni principali.

## Suggerimenti ulteriori
- Valutare l'aggiunta di sensori di runtime specifici per la VMC (ore/cicli) per popolare meglio la sezione "Runtime e cicli".
- Introdurre, se utile, sensori sintetici per modalità AC (es. label leggibile) in modo da arricchire i KPI senza ricorrere a entità non ufficiali.
