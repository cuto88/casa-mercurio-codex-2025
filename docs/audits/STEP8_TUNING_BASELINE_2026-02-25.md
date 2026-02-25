# STEP8 Tuning Baseline (2026-02-25)

Date: 2026-02-25  
Scope: avvio fase di tuning post-closure Step7.

## Obiettivo Step8
Ottimizzare soglie forecast/tariff/grid e monitorare KPI AEB su finestra multi-giorno
senza regressioni su stabilita` attuatori.

## Baseline iniziale (FACT)
Fonte: `/homeassistant/.storage/core.restore_state` (snapshot runtime) + config repo.

### Soglie correnti
- `input_number.policy_forecast_pv_min_w = 300`
- `input_number.policy_grid_price_expensive_threshold = 0.35 EUR/kWh`
- `input_number.policy_grid_price_cheap_threshold = 0.15 EUR/kWh`
- `input_number.policy_grid_import_high_w = 2500 W`
- `input_boolean.policy_enable_tariff_grid = off`

### KPI snapshot
- `sensor.aeb_self_consumption_ratio_pct = 0`
- `sensor.aeb_shift_effectiveness_pct = 60`
- `sensor.aeb_comfort_energy_score_pct = 88.0`
- `sensor.aeb_policy_activation_rate_pct = 0`

## Evidenza
- `docs/runtime_evidence/2026-02-25/step7_state_snapshot_20260225_220506.txt`
- `docs/runtime_evidence/2026-02-25/step7_live_states_20260225_222310.txt`

## Piano tuning (7 giorni)
1. Giorno 1-2: osservazione passiva con `policy_enable_tariff_grid=off`.
2. Giorno 3-4: attivazione controllata (`policy_enable_tariff_grid=on`) in fascia ridotta.
3. Giorno 5: revisione soglia `policy_grid_import_high_w` se rilevati blocchi frequenti.
4. Giorno 6: revisione soglia `policy_forecast_pv_min_w` in base alla qualita` feed.
5. Giorno 7: consolidamento + confronto KPI vs baseline.

## Criteri di successo Step8
- Nessuna regressione funzionale su `cm_system_mode_suggested`/attuazione.
- Riduzione finestre `HOLD_*` non desiderate a parita` comfort.
- KPI AEB coerenti con policy attiva (attivazione > 0 con flag ON).

## Rollback operativo
- Impostare `input_boolean.policy_enable_tariff_grid=off`.
- Ripristinare soglie baseline sopra riportate.
