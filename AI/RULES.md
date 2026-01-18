# RULES

## Hard rules (non negoziabili)
1. Non rinominare alcun `entity_id` già in produzione; per il clima è vietato in modo assoluto salvo richiesta esplicita.
2. Per il clima usare sempre la entity map canonica come unica fonte di verità.
3. Non modificare o esporre secrets/tokens/credenziali.
4. Non introdurre duplicati/alias di KPI o sensori esistenti.
5. Cambiamenti solo dove richiesto: evitare side‑effects fuori scope.
6. Un task = un branch = una PR (policy desiderata).
7. Ogni modifica deve includere: elenco file toccati, motivazione, rischi, rollback.
8. Conservare coerenza con le regole core (priorità/lock/hook) del clima.
9. Non eliminare entità/helper/automazioni senza richiesta esplicita.
10. Aggiornare documentazione correlata quando si introduce nuova logica.
11. Verificare include tree prima di chiudere il lavoro.
12. Nessuna modifica non tracciata/anonima: tutto deve passare da commit.

## Scope & Ownership
- **Codice HA**: `configuration.yaml`, `packages/`, `lovelace/`, `automations/`, `scripts/`, `templates/`, `themes/`.
- **Documentazione logica**: `logica/` (solo doc/testi).
- **Ops/strumenti**: `ops/` (script di manutenzione e check).
- **Altri asset**: `mirai/` e relativi backup.

## Quality gates minimi (manuali per ora)
- `yamllint` su YAML del repo.
- `homeassistant check_config`.
- Controllo include tree (entrypoint + file Lovelace referenziati esistono).
- Controllo entity map (nessun rename/alias per `entity_id` clima).
