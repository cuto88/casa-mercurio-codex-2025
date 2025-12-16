# Casa Mercurio Codex 2025

Configurazione Home Assistant organizzata per funzioni e componenti modulari.

## Struttura cartelle
- `packages/` – logica principale suddivisa per dominio.
- `mirai/` – runtime e configurazione custom del progetto Mirai.
- `logica/` – automazioni/script di alto livello (structured packages).
- `lovelace/` – dashboard YAML.
- `docs/modbus/` – documentazione tecnica Modbus (solo locale, non sincronizzata su HA).
- `tools/` – utilità di sviluppo locali (non sincronizzate su HA).
- `ops/` – script di sincronizzazione e manutenzione (non sincronizzati su HA).

Ulteriori dettagli tecnici sono nel documento dedicato [README_ClimaSystem.md](README_ClimaSystem.md).

## Sync verso Home Assistant
Solo queste cartelle/file vengono replicate su Home Assistant (`Z:\\config`):
`packages/`, `mirai/`, `logica/`, `lovelace/`, `www/`, `custom_components/`, `blueprints/`, insieme ai file di configurazione necessari (es. `configuration.yaml`).
Le cartelle `tools/`, `ops/`, `docs/` e gli altri file di root non vengono sincronizzati.
