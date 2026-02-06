# EcoHotWater (EHW) — ENTITY MAP (canonical)

Single source of truth per le entità EHW via Modbus TCP.
Tutti i package EHW **devono** usare **esattamente** questi `entity_id`.

> Nota: naming in inglese, descrizioni in italiano.

---

## Overview (scope)

Questa mappa copre il layer Modbus TCP EcoHotWater con lettura di registri holding
(FC3, addressing 0-based/PDU). Include sensori raw, hex decoding e flag binari da
status word.

Manuale di riferimento previsto in: `docs/vendor/ehw/Ecohotwater 2021 - manual_compressed.pdf`.

---

## Entity map (canonical)

| Entity ID canonico                 | Tipo           | Source (reg / FC) | Scala | Unità | Significato / note |
|------------------------------------|----------------|-------------------|-------|-------|--------------------|
| `sensor.ehw_reg56_status`          | modbus sensor  | 56 / FC3 holding  | 1:1   | raw   | Status word (uint16) |
| `sensor.ehw_reg57_runtime`         | modbus sensor  | 57 / FC3 holding  | 1:1   | raw   | Runtime word (uint16) |
| `sensor.ehw_reg60_value`           | modbus sensor  | 60 / FC3 holding  | 1:1   | raw   | Observed value (uint16), visto stabile a 0x002D/45 |
| `sensor.ehw_status_word_hex`       | template sensor| reg56             | n/a   | hex   | Status word formattato 0x%04X |
| `sensor.ehw_runtime_word_hex`      | template sensor| reg57             | n/a   | hex   | Runtime word formattato 0x%04X |
| `binary_sensor.ehw_status_bit_0100`| template binary| reg56             | n/a   | bool  | Bit 0x0100 (mask 256) |
| `binary_sensor.ehw_status_bit_0200`| template binary| reg56             | n/a   | bool  | Bit 0x0200 (mask 512) |

---

## Known constraints

- Il setpoint **non è esposto in chiaro**: il cambio setpoint si riflette su reg56/reg57,
  mentre reg60 resta 0x002D/45 nei test.

---

## Validation procedure (modpoll)

Assunzioni: Modbus TCP, slave 1, addressing 0-based (PDU), FC3 holding.

1) Leggi frame 50–81 in hex:
```
modpoll -m tcp -a 1 -r 50 -c 32 -t 4:hex 192.168.178.191
```

2) Leggi singoli registri 56/57/60:
```
modpoll -m tcp -a 1 -r 56 -c 1 -t 4:hex 192.168.178.191
modpoll -m tcp -a 1 -r 57 -c 1 -t 4:hex 192.168.178.191
modpoll -m tcp -a 1 -r 60 -c 1 -t 4:hex 192.168.178.191
```
