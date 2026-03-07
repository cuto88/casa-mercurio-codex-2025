# STEP27 MIRAI - Manuale RS485 vs Gateway Modbus TCP (2026-03-07)
Date: 2026-03-07
Scope: documentare la divergenza tra manuale vendor e comportamento runtime attuale, con decisione di remediation posticipata.

> Update 2026-03-07 (successivo): remediation eseguita in `STEP29_RUNTIME_HOST_UNIT_REALIGNMENT_2026-03-07.md`.

## Sintesi
- Il manuale MIRAI indica profilo RS485 con `address 1`.
- In Home Assistant il polling avviene via Modbus TCP gateway, dove il profilo che oggi risponde in modo operativo e` `unit/slave 3` su `192.168.178.190`.
- Il polling continuo anche su `unit/slave 1` genera errori ricorrenti e rumore log.

## Evidenze principali
- Errori runtime ripetuti su `device: 1`:
  - `docs/runtime_evidence/2026-03-07/phase1_runtime_truth_logs_20260307_073137.txt`
- Configurazione attuale con doppio profilo (`slave: 1` + `slave: 3`):
  - `packages/mirai_modbus.yaml`
- Scan mapping host/unit:
  - `tmp/ip_mapping_scan_20260301_163218.json`
  - `192.168.178.190`: `unit_3` risponde sui registri MIRAI principali, `unit_1` non stabile/null.

## Root cause tecnica (confermata)
- Differenza di livello protocollo:
  - manuale: indirizzamento lato bus RS485 nativo macchina;
  - runtime HA: indirizzamento lato gateway Modbus TCP.
- L'address del manuale non e` automaticamente trasferibile 1:1 al `unit id` effettivo esposto dal gateway.

## Impatto
- Errori Modbus ricorrenti nei log HA.
- Segnale operativo confuso (mix tra probe manuale e fallback runtime).
- Gate runtime attuali troppo permissivi rispetto a questo tipo di errore.

## Decisione operativa
- Nessun cutover immediato in questo step.
- Remediation tecnica rinviata a fase successiva pianificata.

## Piano per la fase successiva (TODO)
1. Limitare il polling continuo MIRAI al profilo runtime valido (`host 192.168.178.190`, `unit 3`).
2. Spostare il profilo `unit 1` in diagnostica on-demand (non polling continuo).
3. Eseguire finestra RUN reale 45-60 min per consolidare registri dinamici utili.
4. Aggiornare gate runtime per intercettare esplicitamente errori Modbus `device: 1`.

## Stato
- Stato corrente: documentato e accettato.
- Prossima azione: implementazione tecnica rinviata.
