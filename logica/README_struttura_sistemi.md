# 🧭 Struttura sistemi Casa Silea — logica/

Panoramica aggiornata della cartella `logica/` dopo la semplificazione: separa le regole core, i file di logica per modulo e le plance documentate.

## 📂 Struttura ad albero
```
logica/
├─ core/
│  ├─ regole_core_logiche.md      ← convenzioni, priorità, lock, hook
│  └─ regole_plancia.md           ← linee guida UI comuni
├─ 1_vent/
│  ├─ 1_vent.txt                  ← logica ventilazione naturale
│  └─ 1_vent_plancia_regole.txt   ← layout plancia 1_vent
├─ 2_vmc/
│  ├─ 2_vmc.txt                   ← logica VMC
│  └─ 2_vmc_plancia_regole.txt    ← layout plancia VMC
├─ 3_heating/
│  ├─ 3_heating.txt               ← logica riscaldamento a pavimento
│  └─ 3_heating_plancia_regole.txt← layout plancia heating
├─ 4_ac/
│  ├─ 4_ac.txt                    ← logica climatizzazione
│  └─ 4_ac_plancia_regole.txt     ← layout plancia AC
├─ 5_energy_pm/
│  └─ 5_pm_plancia_regole.txt     ← layout plancia power meter
├─ 6_surplus/
│  ├─ 6_surplus.txt               ← logica surplus energetico
│  └─ 6_surplus_plancia_regole.txt← layout plancia surplus
├─ 9_debug_test/
│  ├─ 9_debug_sistema_plancia_regole.txt ← plancia diagnostica
│  └─ 9_test_plancia_regole.txt           ← plancia test
├─ _archive/
│  └─ vmc_plancia_regole.txt      ← versione storica plancia VMC
├─ README_struttura_sistemi.md    ← questo file
├─ _sistema.txt                   ← schema fisico sensori/attuatori
├─ regole_chat_gpt.txt            ← istruzioni operative GPT
├─ regole_plancia.txt             ← legacy (rimando ai file core)
├─ _report_semplificazione_logica.md
└─ _proposta_operativa_semplificazione.md
```

## 🎛️ Ruoli dei file
- **core/**: unica fonte per convenzioni, priorità P0–P4, lock e hook cross-modulo (regole_core_logiche) e per le linee guida UI generali (regole_plancia).
- **Cartelle numerate**: contengono coppie `logica` + `plancia` specifiche del modulo; le plance riportano solo layout e rimandi ai documenti core.
- **_archive/**: conserva versioni storiche non più attive (es. vecchia plancia VMC).
- **File legacy**: `regole_plancia.txt` marcato deprecato; usare i documenti in core.
- **Documenti di progetto**: `_report_semplificazione_logica.md` e `_proposta_operativa_semplificazione.md` tracciano motivazioni e step.

## 🔗 Collegamento con YAML
Ogni file `.txt` corrisponde a un package YAML e alla relativa plancia Lovelace omonima. Le soglie e i lock devono essere presi dal core; i moduli dichiarano solo le eccezioni locali. Le plance includono sempre la sezione **RIFERIMENTI LOGICI** con link al core e al file logico del modulo.
