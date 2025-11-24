# Clima System — Audit

## Errori e incongruenze individuate
- **Plancia ventilazione (AQ)**: il blocco Meteo/AQ referenziava `sensor.pm2_5`, entità non definita in nessun package. La sorgente corretta creata dal modulo ventilazione è `sensor.vent_meteo_pm25`, quindi la card risultava vuota/unknown.
- **Priorità VMC non aderente allo standard**: in `sensor.vmc_priority` l'anti-secco era etichettato "P3" e il freecooling "P2", invertendo l'ordine previsto da README_ClimaSystem (anti-secco P1, freecooling P3). Questo rendeva incoerenti reason/priority rispetto alla gerarchia ufficiale e poteva confondere la plancia.

## Entità mancanti o naming errato
- `sensor.pm2_5` non esiste nello scope; è sostituito da `sensor.vent_meteo_pm25`.

## Template / logica
- Priorità VMC riallineata: anti-secco ora esplicitamente P1, freecooling P3 come da specifica.

## Plance da fixare
- **1_ventilation_plancia.yaml**: aggiornato il riferimento AQ a `sensor.vent_meteo_pm25` per popolare il pannello.

## Verifica copertura
- Nessuna proposta di rimozione file o moduli; modifiche limitate ai file richiesti.
