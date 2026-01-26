# 🧭 Struttura sistemi Casa Silea — docs/logic/

Panoramica aggiornata della cartella `docs/logic/` dopo la semplificazione: separa le regole core, i file di logica per modulo e le plance documentate.

## 🧩 Standard di riferimento
- **Regole globali**: tutte le convenzioni, priorità, lock e hook vivono unicamente in `docs/logic/core/regole_core_logiche.md`; qui risiedono anche le logiche ufficiali e complete per VMC, AC, Heating, Vent e Surplus.
- **Moduli numerati (1_vent, 3_heating, 4_ac, 5_powermeter, 6_surplus, 9_debug)**:
  - `docs/logic/<modulo>/README.md` (o equivalente) contiene logica locale, eccezioni e mappa sensori/attuatori.
  - `docs/logic/<modulo>/plancia.md` (o equivalente) definisce solo layout e KPI della plancia Lovelace.
  - Nessuna logica duplicata dentro i file di plancia: le regole puntano sempre al core per priorità, lock e hook.
- **Documentazione soltanto**: la cartella `docs/logic/` ospita solo documenti testuali (nessun YAML o automazione).
- **Collegamenti ai package**: i moduli fanno riferimento al core per le regole condivise e dichiarano solo le eccezioni locali.
- **Consolidamento VMC**: la logica VMC vive nel modulo `1_vent`, insieme a ventilazione naturale e diagnostica.

## 📂 Struttura ad albero
```
docs/logic/
├─ core/
│  ├─ regole_core_logiche.md      ← convenzioni, priorità, lock, hook e logiche ufficiali
│  └─ regole_plancia.md           ← linee guida UI comuni
├─ 1_vent/
│  ├─ README.md                   ← logica ventilazione naturale + VMC
│  ├─ plancia.md                  ← layout plancia 1_vent
│  ├─ vmc.md                      ← approfondimento VMC (meccanica)
├─ 3_heating/
│  ├─ 3_heating.txt               ← logica riscaldamento a pavimento
│  └─ 3_heating_plancia_regole.txt← layout plancia heating
├─ 4_ac/
│  ├─ 4_ac.txt                    ← logica climatizzazione
│  └─ 4_ac_plancia_regole.txt     ← layout plancia AC
├─ 5_energy_pm/
│  └─ 5_pm_plancia_regole.txt     ← layout plancia power meter (5_powermeter)
├─ 6_surplus/
│  ├─ 6_surplus.txt               ← logica surplus energetico
│  └─ 6_surplus_plancia_regole.txt← layout plancia surplus
├─ _backup/
│  ├─ archive/                    ← versioni storiche (es. plancia VMC legacy)
│  └─ doc/                        ← documenti di progetto
├─ _backup_legacy/                ← spazio per file legacy o non allineati
└─ README_struttura_sistemi.md    ← questo file
```

## 🎛️ Ruoli dei file
- **core/**: unica fonte per convenzioni, priorità P0–P4, lock e hook cross-modulo (regole_core_logiche) e per le linee guida UI generali (regole_plancia).
- **Cartelle numerate**: contengono coppie `logica` + `plancia` specifiche del modulo; le plance riportano solo layout e rimandi ai documenti core.
- **_backup/**: conserva versioni storiche non più attive e la documentazione di progetto.
- **_backup_legacy/**: raccoglie file legacy, bozze e risorse temporanee non allineate allo standard.

## 🔗 Collegamento con YAML
Ogni documento di logica corrisponde a un package YAML e alla relativa plancia Lovelace omonima, ma la cartella `docs/logic/` rimane soltanto documentale. Le soglie e i lock devono essere presi dal core; i moduli dichiarano solo le eccezioni locali. Le plance includono sempre la sezione **RIFERIMENTI LOGICI** con link al core e al file logico del modulo.

## 🌡️ Clima 2025 — stack attivo
- **Packages:** `0_sensors.yaml`, `1_ventilation.yaml`, `1_ventilation_windows.yaml`, `2_heating.yaml`, `climate_ac_mapping.yaml`, `climate_ac_logic.yaml`.
- **Plance Lovelace:** `1_ventilation_plancia.yaml`, `1_ventilation_windows.yaml`, `2_heating_plancia.yaml`, `3_ac_plancia.yaml`.

> Revisione documentazione clima Vent – allineata a implementazione attuale.
