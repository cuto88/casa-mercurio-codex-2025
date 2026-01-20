# Step 4 — Runtime audit (UNKNOWN → USED/ORPHAN)

> Scope: **blueprints/** and **custom_components/** only. No runtime access detected in this environment, so findings are limited to static analysis + a UI checklist for manual verification.

## Summary

- **Blueprints**: 4 total
  - Used: 0 (runtime evidence unavailable)
  - Orphan: 0 (no runtime proof)
  - Unknown: 4
- **Custom components**: 5 total
  - Used: 0 (runtime evidence unavailable)
  - Orphan: 0 (no runtime proof)
  - Unknown: 5

## Step 4A — Static inventory + static hints (non‑proof)

### Inventory

**Blueprints**
- `blueprints/template/homeassistant/inverted_binary_sensor.yaml`
- `blueprints/automation/homeassistant/notify_leaving_zone.yaml`
- `blueprints/automation/homeassistant/motion_light.yaml`
- `blueprints/script/homeassistant/confirmable_notification.yaml`

**Custom components (with manifest domain)**
- `custom_components/hacs` (domain: `hacs`)
- `custom_components/localtuya` (domain: `localtuya`)
- `custom_components/meross_cloud` (domain: `meross_cloud`)
- `custom_components/nodered` (domain: `nodered`)
- `custom_components/sonoff` (domain: `sonoff`)

### Static reference scan (non‑proof)

- **Blueprint references**: no `blueprint:` usage found outside `blueprints/**`.
- **Custom component references**:
  - `configuration.yaml` contains `/hacsfiles/…` frontend include (weak signal that HACS is/was used).
  - No other explicit references to `localtuya`, `meross_cloud`, `nodered`, or `sonoff` found outside `custom_components/**`.

### Static classification table (not runtime evidence)

| ITEM | TIPO | PROVA STATICA | RISCHIO | STATO (statico) |
| --- | --- | --- | --- | --- |
| `inverted_binary_sensor.yaml` | Blueprint (template) | Nessun riferimento `blueprint:` trovato | Medio | UNKNOWN |
| `notify_leaving_zone.yaml` | Blueprint (automation) | Nessun riferimento `blueprint:` trovato | Medio | UNKNOWN |
| `motion_light.yaml` | Blueprint (automation) | Nessun riferimento `blueprint:` trovato | Medio | UNKNOWN |
| `confirmable_notification.yaml` | Blueprint (script) | Nessun riferimento `blueprint:` trovato | Medio | UNKNOWN |
| `custom_components/hacs` | Custom component | `configuration.yaml` include `/hacsfiles/…` (debole) | Basso | LIKELY_USED |
| `custom_components/localtuya` | Custom component | Nessuna evidenza statica | Medio | UNKNOWN |
| `custom_components/meross_cloud` | Custom component | Nessuna evidenza statica | Medio | UNKNOWN |
| `custom_components/nodered` | Custom component | Nessuna evidenza statica | Medio | UNKNOWN |
| `custom_components/sonoff` | Custom component | Nessuna evidenza statica | Medio | UNKNOWN |

## Step 4B — Runtime audit (UI checklist, preferito)

> **Da eseguire manualmente in Home Assistant UI** (Settings / Impostazioni).

### B1) Automations & Scenes → Automations
1. Filtra per **Blueprint**.
2. Per ogni automation basata su blueprint, annota **nome** e **blueprint di origine** (path/id).
3. Compila una lista: *Blueprint → Automations che lo usano*.

### B1) Devices & Services → Integrations
1. Per ognuna delle cartelle in `custom_components/`, verifica se l’integrazione è caricata.
2. Registra evidenza: **nome integrazione**, **stato**, **n. dispositivi/entità**.
3. Lista target:
   - HACS (`hacs`)
   - LocalTuya (`localtuya`)
   - Meross Cloud (`meross_cloud`)
   - Node-RED Companion (`nodered`)
   - SonoffLAN (`sonoff`)

### B1) System → Logs
1. Cerca errori relativi a `custom_components` o blueprint.
2. Segnala eventuali errori di load (indicativi di utilizzo o problematiche).

## Step 4C — Classificazione finale (evidence‑based)

> In assenza di runtime access, **tutti gli elementi restano UNKNOWN** fino a prova contraria.

### USED (runtime evidence)
- Nessuna evidenza runtime raccolta in questo step.

### ORPHAN (runtime evidence)
- Nessuna evidenza runtime raccolta in questo step.

### UNKNOWN (manca evidenza)
**Blueprints**
- `inverted_binary_sensor.yaml`
- `notify_leaving_zone.yaml`
- `motion_light.yaml`
- `confirmable_notification.yaml`

**Custom components**
- `hacs`
- `localtuya`
- `meross_cloud`
- `nodered`
- `sonoff`

**Cosa manca per chiuderli:**
- Evidenza UI (B1) o API che confermi blueprint usati e integrazioni caricate.

## Step 4D — Quarantine plan (solo ORPHAN certi)

- **Nessun oggetto spostato**: non esistono ORPHAN certi senza evidenza runtime.
- Se/Quando si otterrà evidenza ORPHAN, applicare la procedura:
  1. Creare:
     - `/_quarantine/20260120_cleanup/runtime_orphans/blueprints/`
     - `/_quarantine/20260120_cleanup/runtime_orphans/custom_components/`
  2. Spostare **solo** ORPHAN certi con `git mv`.
  3. Aggiornare `/_quarantine/20260120_cleanup/README.md` con evidenze e rollback.
  4. Gate post‑move: `ha core check` + log clean all’avvio.

## Comandi richiesti (bash + PowerShell)

### Inventory
**bash**
```bash
find blueprints -type f
ls custom_components
find custom_components -maxdepth 2 -type f -name manifest.json -print
```

**PowerShell**
```powershell
Get-ChildItem -Recurse -File blueprints
Get-ChildItem custom_components -Directory
Get-ChildItem -Recurse -Filter manifest.json custom_components
```

### Static references (grep)
**bash**
```bash
rg -n "blueprint:" -S -g '!custom_components/**' -g '!www/**' -g '!lovelace/**' -g '!blueprints/**' .
rg -n "motion_light|notify_leaving_zone|confirmable_notification|inverted_binary_sensor" -S -g '!custom_components/**' -g '!www/**' -g '!lovelace/**' -g '!blueprints/**' .
rg -n "hacs|localtuya|meross_cloud|nodered|sonoff" -S -g '!custom_components/**' -g '!www/**' -g '!lovelace/**' .
```

**PowerShell**
```powershell
rg -n "blueprint:" -S -g '!custom_components/**' -g '!www/**' -g '!lovelace/**' -g '!blueprints/**' .
rg -n "motion_light|notify_leaving_zone|confirmable_notification|inverted_binary_sensor" -S -g '!custom_components/**' -g '!www/**' -g '!lovelace/**' -g '!blueprints/**' .
rg -n "hacs|localtuya|meross_cloud|nodered|sonoff" -S -g '!custom_components/**' -g '!www/**' -g '!lovelace/**' .
```

### Quarantine moves (solo se ORPHAN certi)
**bash**
```bash
mkdir -p /_quarantine/20260120_cleanup/runtime_orphans/blueprints/
mkdir -p /_quarantine/20260120_cleanup/runtime_orphans/custom_components/
# esempio:
# git mv blueprints/automation/homeassistant/motion_light.yaml /_quarantine/20260120_cleanup/runtime_orphans/blueprints/
# git mv custom_components/sonoff /_quarantine/20260120_cleanup/runtime_orphans/custom_components/
```

**PowerShell**
```powershell
New-Item -ItemType Directory -Force /_quarantine/20260120_cleanup/runtime_orphans/blueprints/
New-Item -ItemType Directory -Force /_quarantine/20260120_cleanup/runtime_orphans/custom_components/
# esempio:
# git mv blueprints/automation/homeassistant/motion_light.yaml /_quarantine/20260120_cleanup/runtime_orphans/blueprints/
# git mv custom_components/sonoff /_quarantine/20260120_cleanup/runtime_orphans/custom_components/
```

## Gate output

- **Gate non eseguito** (nessuno spostamento effettuato).
