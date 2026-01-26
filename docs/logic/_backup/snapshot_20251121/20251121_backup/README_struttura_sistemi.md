# 🧭 Documento di riferimento — Struttura sistemi Casa Silea (Passivhaus-oriented)

## 🔍 Obiettivo generale
Creazione di un **ecosistema modulare e coerente di automazioni Home Assistant** che gestisce:
- **ventilazione naturale**
- **VMC**
- **riscaldamento a pavimento**
- **aria condizionata (AC)**

secondo logiche **Passivhaus-oriented**, massimizzando comfort, efficienza e autonomia energetica, evitando conflitti tra sistemi.

Ogni funzione è contenuta in un file indipendente `.yaml` (logica attiva) o `.txt` (documentazione e criteri), che definisce:
- la **logica di attivazione** e le **priorità di arbitraggio**
- le **entità coinvolte** (sensori, input, switch, boolean)
- la **spiegazione leggibile** della logica umana
- la **plancia Lovelace** coerente con le stesse regole grafiche

---

## 🧩 Struttura modulare dei file

```
/config
│
├── /packages
│   │
│   ├── 0_sensors.yaml
│   ├── 1_ventilation.yaml
│   ├── 1_ventilation.yaml
│   ├── 2_heating.yaml
│   ├── 3_ac.yaml
│   ├── 6_powermeter.yaml
│   ├── 6_surplus_energy.yaml
│   ├── 6_global_energy.yaml
│   └── backup_shell.ps1
│
└── /lovelace
    ├── resources.yaml
    ├── 1_vent_plancia.yaml
    ├── 2_vmc_plancia.yaml
    ├── 3_heating_plancia.yaml
    ├── 4_ac_plancia.yaml
    ├── 5_pm_plancia.yaml
    ├── 6_surplus_plancia.yaml

    ├── /logica/              ← documentazione tecnica e regole operative
│    ├── _sistema.txt
│    ├── 1_vent.txt
│    ├── 2_vmc.txt
│    ├── 2_vmc1.txt
│    ├── 3_heating.txt
│    ├── 4_ac.txt
│    ├── regole_plancia.txt

## 🧠 Moduli e funzioni

| Modulo | Logica | Scopo sintetico |
|:--|:--|:--|
| **Ventilazione naturale** | `1_ventilation.yaml` / `1_vent.txt` | Suggerisce quando aprire/chiudere finestre per free-cooling notturno e comfort estivo (ΔT e ΔAH). |
| **VMC** | `1_ventilation.yaml` / `2_vmc1.txt` | Gestisce priorità P0–P4: failsafe, bagno/boost, free-cooling PH o termico, anti-secco, baseline. Override AC notte. |
| **Riscaldamento** | `2_heating.yaml` / `3_heating.txt` | Ottimizza il riscaldamento a pavimento in base a PV e comfort. Funzione “carica termica” 10-16. |
| **AC** | `3_ac.yaml` / `4_ac.txt` | Gestisce modalità DRY/COOL, isteresi, anti-ciclo, lock, con priorità comfort. Blocchi notturni integrabili con VMC. |
| **Energia / PowerMeter** | `5_powermeter.yaml` | Rileva potenza e flussi (A/B), base per logiche di surplus e bilancio. |
| **Surplus PV** | `6_surplus_energy.yaml` | Gestisce carichi e logiche di autoconsumo energetico intelligente. |
| **Energia globale** | `9_global_energy.yaml` | Aggrega KPI, bilanci e grafici cumulativi. |
| **Sistema fisico** | `_sistema.txt` | Descrive sensori, termostati, mandata/ripresa per tutte le zone. |
| **Regole plancia v2** | `regole_plancia.txt` | Definisce layout, colori, sezioni e standard visivo per tutte le dashboard. |

---

## ⚙️ Principi di progettazione

1. **Indipendenza logica** → ogni file YAML funziona da solo, senza dipendenze rigide.  
2. **Arbitraggio chiaro** → priorità esplicite (es. `AC notte = DRY` forza VMC OFF).  
3. **Trasparenza** → ogni plancia include la card “Come decide”, spiegazione leggibile per l’utente.  
4. **Scalabilità** → sensori, lock, override e logging facilmente espandibili.  
5. **Coerenza visiva** → tutti i moduli seguono `regole_plancia2.txt` (colori, layout, sezioni).  
6. **Versionabilità** → la logica testuale (.txt) rimane sincronizzata con l’automazione YAML.  

---

## 🎯 Obiettivo finale

Costruire una **suite coordinata e trasparente** che permetta di:
- comprendere *a colpo d’occhio* chi comanda cosa e perché  
- analizzare l’efficacia di strategie (boost, free-cooling, anti-secco, PV-window)  
- modificare in tempo reale soglie e parametri (input_number, boolean)  
- ottenere comfort e risparmio energetico con logiche *Passivhaus* ma operatività *Home Assistant*
