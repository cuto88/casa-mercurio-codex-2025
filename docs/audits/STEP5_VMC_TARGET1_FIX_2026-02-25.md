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
- se `input_boolean.climateops_cutover_vmc = off`, l'automazione non forza piu` i rami `VENT_*` ma applica direttamente `sensor.vmc_vel_target` su `switch.vmc_vel_*`;
- quindi `target=1` non viene piu` ribaltato a `3` dal ramo di mode policy.

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

## Update 2 - Boost bagno e rientro (2026-02-25)
Durante test runtime guidato e` emerso un secondo difetto:
- con `input_boolean.vmc_boost_bagno = on`, `sensor.vmc_vel_target` passava a `3`;
- allo spegnimento boost, `sensor.vmc_vel_target` tornava a `1`;
- ma la velocita` fisica poteva non seguire (restava su indice alto).

### Causa
Nel blocco `choose` principale di `automation.climateops_system_actuate`, il ramo `mode == 'IDLE'` matchava prima dei rami VMC.
In Home Assistant, `choose` esegue solo il primo ramo vero: i rami VMC venivano quindi saltati.

### Correzione
Refactor dell'azione in blocchi separati:
- `choose` heating dedicato
- `choose` VMC dedicato
- `choose` AC giorno dedicato
- `choose` AC notte dedicato

Con questa struttura, la logica VMC viene sempre valutata indipendentemente dal ramo heating.

### Esito test funzionale
Dopo deploy + `ha core restart`:
- boost ON: velocita` sale correttamente;
- boost OFF: rientro correttamente alla velocita` base.

Stato: issue chiusa operativamente.
