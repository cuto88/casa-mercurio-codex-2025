# STEP5 VMC target=1 overwrite fix (2026-02-25)

## Obiettivo
Risolvere il bug per cui, quando il target VMC e` `1`, la velocita` veniva riportata a `3`.

## Root cause
L'automazione `automation.climateops_system_actuate` comandava direttamente gli switch VMC (`switch.vmc_vel_*`) anche quando il cutover VMC era disattivato.

In pratica c'erano due writer concorrenti:
- writer legacy (`sensor.vmc_vel_target` -> attuazione legacy)
- writer ClimateOps (`climateops_system_actuate`)

Senza gate sul cutover, il writer ClimateOps poteva sovrascrivere il target legacy.

## Fix applicato
File: `packages/climateops/actuators/system_actuator.yaml`

Modifiche:
- aggiunta variabile `vmc_cutover_on: "{{ is_state('input_boolean.climateops_cutover_vmc','on') }}"`
- aggiunta condizione `(vmc_cutover_on | bool)` ai rami VMC:
  - `mode == 'VENT_BOOST'`
  - `mode in ['VENT_BASE', 'IDLE']` (e fallback `VENT_BOOST` policy off)

Effetto:
- se `input_boolean.climateops_cutover_vmc = off`, ClimateOps non scrive piu` la velocita` VMC;
- resta autorita` il flusso legacy, quindi `target=1` non viene ribaltato a `3` da ClimateOps.

## Deploy e verifiche runtime
Data verifica: 2026-02-25

Comandi eseguiti:
- deploy file patchato su runtime: `/homeassistant/packages/climateops/actuators/system_actuator.yaml`
- `ha core check` -> OK
- `ha core restart` -> OK

Campionamento runtime (4 campioni in ~5 minuti, da `core.restore_state`):
- `input_boolean.climateops_cutover_vmc = off`
- `sensor.vmc_vel_target = 1`
- `sensor.vmc_vel_index = 1`
- nessun rientro osservato a indice `3` nella finestra di verifica

## Limiti evidenza
Dalla shell SSH add-on non e` stato possibile eseguire interrogazione completa delle API Core con correlazione `context_id` (restrizioni auth `401` sul proxy supervisor/core in questo contesto).

Conclusione operativa: fix efficace sul caso riportato (`target=1` che restava a `3`) e deploy completato.
