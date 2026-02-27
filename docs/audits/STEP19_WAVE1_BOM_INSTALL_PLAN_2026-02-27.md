# STEP19 Wave1 BOM + Install Plan (2026-02-27)

Date: 2026-02-27  
Scope: definire componenti e piano esecutivo Wave1 (ROI alto) per ottimizzazione AEB.

## 1) BOM Wave1 (proposta)

## A. Metering HVAC dedicato (Priorita` Alta)

1. Linee da misurare:
- AC giorno/notte (linea/e alimentazione split)
- VMC
- Heating relay/circuito riscaldamento

2. Opzioni hardware:
- Shelly Pro EM-50 (DIN, CT esterni) oppure Shelly 3EM Pro (se multi-linea)
- Alternativa: Sonoff POW Elite / smart DIN meter con integrazione HA stabile

3. Quantita` suggerita:
- 2-3 canali misurazione (minimo), meglio 4 per separare AC giorno/notte

4. Costo indicativo:
- fascia 180-450 EUR totale (dipende da numero canali + TA + quadro)

## B. IAQ CO2 (Priorita` Alta)

1. Zone:
- Giorno
- Notte

2. Sensori consigliati:
- Sensirion SCD41/SCD40 based (es. Apollo/ESPHome-ready)
- oppure Netatmo/Aranet/NDIR equivalenti con integrazione HA affidabile

3. Quantita`:
- 2 unita`

4. Costo indicativo:
- fascia 140-350 EUR totale

## C. Forecast PV robustezza (Priorita` Alta)

1. Feed primario:
- mantenere feed attuale policy forecast

2. Feed secondario:
- aggiungere provider ridondante (es. Solcast o equivalente gia` integrabile)

3. Costo:
- 0-150 EUR/anno (in base al piano provider)

## 2) Mappatura entity target (no nuovi writer)

1. Nuovi sensori energia (esempio naming):
- `sensor.hvac_ac_power_w`
- `sensor.hvac_vmc_power_w`
- `sensor.hvac_heating_power_w`

2. Nuovi sensori CO2:
- `sensor.co2_giorno`
- `sensor.co2_notte`

3. Vincolo:
- Solo telemetria/KPI/policy input; nessuna scrittura diretta su attuatori.

## 3) Sequenza installativa (operativa)

1. Pre-check elettrico/quadro:
- identificazione linee AC/VMC/heating.

2. Installazione metering HVAC:
- montaggio e validazione letture in HA.

3. Installazione CO2:
- posizionamento in zone target e calibrazione iniziale.

4. Forecast ridondante:
- configurazione secondo provider, verifica disponibilita` entity.

5. Integrazione dashboard:
- vista Executive/Diagnostics: aggiunta card KPI nuovi (additiva).

## 4) Piano di validazione KPI

1. Baseline pre-wave:
- 7 giorni con KPI attuali.

2. Post-wave:
- 7 giorni con nuovi segnali.

3. KPI outcome:
- comfort band % (target: stabile o migliorato),
- cicli heating/AC (target: riduzione oscillazioni inutili),
- grid import in fascia cara (target: riduzione),
- coerenza VMC vs CO2 (target: migliore correlazione IAQ/azione).

## 5) Go/No-Go Wave1

GO se:
1. telemetria stabile (nessun `unknown` persistente sui nuovi sensori),
2. nessun impatto su authority chain attuatori,
3. gates e `ha core check` sempre verdi.

NO-GO se:
1. misure rumorose/non affidabili,
2. regressioni runtime o saturazione log/errori integrazione,
3. drift entity naming non conforme SOT.

## 6) Decisione

- Wave1: **APPROVED (ready to execute)** in modalita` incrementale e reversibile.
