# STEP30 - Telegram channel split (HA vs personale) - 2026-03-07

## Scope
Separare i destinatari Telegram:
- canale tecnico Home Assistant: `telegram_ha_mercurio`
- canale personale: `personale_davide`

## Evidenza raccolta
- Ricerca in `C:\2_OPS` su riferimenti `chat_id`/`TELEGRAM_CHAT_ID`.
- `chat_id` reale usato: `193864452`.
- Token personale fornito in sessione e aggiunto come seconda config entry `telegram_bot` runtime.

## Vincolo tecnico chiarito
Con integrazione `telegram_bot` in Home Assistant:
- due notifier distinti con stesso `chat_id` sono possibili
- requisito: bot diversi (token diversi)

## Stato runtime (chiuso)
- Bot tecnico: entry `HA Mercurio` con subentry `telegram_ha_mercurio`.
- Bot personale: entry `Personale` con subentry `davide`.
- Service tecnico attivo: `notify.telegram_davide` (entity_id storico).
- Service personale attivo: `notify.personale_davide`.

## Note operative
- Il nome service finale dipende da `title` entry + `title` subentry nel registry HA.
- Per invio memo personali usare `notify.davide_personale_personale_davide`.
