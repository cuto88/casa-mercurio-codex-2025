# STEP20 - MIRAI Value Recovery (2026-02-28)

## Obiettivo
Evitare spreco di tempo/energia e trasformare l'integrazione MIRAI in un sistema con beneficio misurabile.

## Stato attuale (evidenza)
- Connettivita` rete confermata verso `192.168.178.190:502`.
- `secrets.yaml` runtime valido (`mirai_modbus_host` presente).
- Config Modbus e template MIRAI ripuliti e deployati senza errori YAML.
- Dopo i fix non ci sono errori recenti `Pymodbus: mirai` nei log post-boot.
- Snapshot runtime recente: registri principali letti ma stabili a `0` (nessuna transizione ON osservata nella finestra test disponibile).

## Cosa e` stato risolto
- Causa software primaria esclusa: non era un problema di `!secret`/IP.
- Storm di errori Modbus ridotto tramite pulizia mappa e parametri.
- Allineamento iniziale su registri che rispondono nel probe (`1003/1208/1209`).
- Correzione template numerici che generavano errori su valori non numerici.

## Cosa manca per ottenere valore reale
- Validare registri dinamici in esercizio reale (compressore ON, non solo idle/stato 0).
- Confermare in modo definitivo coppia:
  - `unit/slave`
  - `function code` (`FC03` vs `FC04`)
  - base addressing (0-based/1-based) rispetto ai manuali installatore.

## Rischio economico (valutazione)
- Rischio principale NON e` "soldi buttati", ma "dati non sfruttati" per mappa incompleta.
- Investimento gia` utile: oggi abbiamo eliminato le incertezze software e identificato chiaramente la fase residua (validazione protocollo in campo).

## Piano operativo di recupero valore (eseguibile)
1. Finestra test guidata 45-60 min con impianto in richiesta reale (riscaldamento).
2. Campionamento strutturato OFF -> START -> RUN STABILE -> STOP con timestamp.
3. Selezione finale registri affidabili (SOT MIRAI) e dismissione registri rumorosi/non utili.
4. KPI minimo di successo:
   - rilevamento certo stato macchina (`OFF`/`RUN`) da Modbus,
   - almeno 1 indicatore tecnico utile stabile (es. status/fault code),
   - dashboard leggibile senza warning bloccanti.

## Gate decisionale
- `GO`: rilevata almeno 1 transizione reale e semantica registri coerente.
- `NO-GO`: nessuna transizione osservabile anche in RUN reale -> coinvolgere installatore per verifica gateway/config Modbus lato macchina.

## Riferimenti evidenze
- `docs/runtime_evidence/2026-02-28/mirai_runtime_snapshot_20260228.txt`
- `docs/runtime_evidence/2026-02-28/mirai_scan_run_20260228_summary.txt`
- `packages/mirai_modbus.yaml`
- `packages/mirai_templates.yaml`
