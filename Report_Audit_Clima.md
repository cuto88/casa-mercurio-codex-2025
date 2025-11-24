# Audit configurazione Clima (VMC, Ventilazione, Heating, AC)

## Sintesi stato generale
- La dashboard Lovelace "1 Ventilazione" era vuota per errori di template: i sensori `sensor.vmc_reason` e `sensor.vmc_freecooling_status` si auto-referenziavano generando TemplateError, impedendo il rendering corretto.
- Le automazioni core della VMC risultano commentate: la logica di controllo VMC e consigli finestre non viene eseguita finché restano disabilitate.
- Non sono stati trovati `device_class: safety` (già assenti); nessun duplicato di entità negli scope analizzati.

## Errori reali individuati
1. **Ricorsione in template VMC** (`packages/1_ventilation.yaml`)
   - `sensor.vmc_reason` e `sensor.vmc_freecooling_status` usavano `state_attr('sensor.vmc_reason', ...)` puntando a se stessi: genera TemplateError (get.__call__) e blocca il sensore.
   - Effetto: valori `unknown`/`unavailable`, automazioni e plance che leggono questi sensori restano senza dati.

2. **Automazioni VMC disabilitate** (`packages/1_ventilation.yaml`)
   - Tutte le automazioni del controller VMC sono commentate: nessuna azione su switch `switch.vmc_vel_*`, nessuna notifica di motivo/priority.
   - Effetto: la logica di controllo non opera; le viste mostrano stato statico.

## Entità mancanti / non valide
- Nessuna entità duplicata rilevata in questi file. Le referenze in Lovelace puntano a sensori presenti nel package; i due sensori ricorsivi erano la causa principale dei dati mancanti.

## Automazioni non validate
- Controller VMC (intero blocco commentato) → non validato/eseguito.

## Template che sollevavano eccezioni
- `sensor.vmc_reason`: auto-referenza.
- `sensor.vmc_freecooling_status`: auto-referenza.

## Plance Lovelace
- **1_ventilation_plancia.yaml**: mostrava pannello bianco perché `sensor.vmc_reason`/`sensor.vmc_freecooling_status` erano `unknown` per TemplateError. Dopo il fix i blocchi Entities/History Graph tornano a popolarsi.
- Le altre plance indicate (2_heating, 3_ac) non presentano errori formali nel YAML; non emergono entità mancanti dagli scope analizzati.

## Come verificare dopo il fix
- Eseguire `ha core check` (o `hass --script check_config`) per validare template e automazioni.
- Aprire la dashboard "1 Ventilazione" e verificare che i riquadri mostrino stati coerenti (Priority/Reason popolati).
- Verificare nei log l'assenza di TemplateError per `sensor.vmc_reason` e `sensor.vmc_freecooling_status`.

