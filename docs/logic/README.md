# Documentazione logica

Questa cartella contiene la documentazione delle logiche di Casa Mercurio.

Nota milestone (2026-02-04): il branch `climateops-skeleton` è in stato CUTOVER OK
(VMC + HEATING + AC), con AC che può risultare `unknown` via IR (atteso).
La nuova architettura ClimateOps è ora referenziata nella cartella `packages/climateops`,
e il lavoro prosegue su `climateops-refactor-cleanup`.

- Panoramica e struttura: [`README_struttura_sistemi.md`](README_struttura_sistemi.md)
- Moduli principali:
  - Ventilation (ventilazione naturale + VMC):
    - [`ventilation/README.md`](ventilation/README.md)
    - [`ventilation/plancia.md`](ventilation/plancia.md)
    - [`ventilation/vmc.md`](ventilation/vmc.md)
  - Heating (pavimento radiante):
    - [`heating/README.md`](heating/README.md)
    - [`heating/plancia.md`](heating/plancia.md)
  - AC (split DRY/COOL):
    - [`ac/README.md`](ac/README.md)
    - [`ac/plancia.md`](ac/plancia.md)
  - Surplus (logica surplus FV):
    - [`surplus/README.md`](surplus/README.md)
    - [`surplus/plancia.md`](surplus/plancia.md)
  - Energy PM (monitor consumi):
    - [`energy_pm/plancia.md`](energy_pm/plancia.md)
    - [`energy_pm/README.md`](energy_pm/README.md)
