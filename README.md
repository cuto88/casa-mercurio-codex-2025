# Casa Mercurio Codex 2025
Configurazione Home Assistant modulare per la casa Mercurio.
Struttura base: packages/, logica/, mirai/, lovelace/.
packages/ contiene automazioni e logica per domini HA.
logica/ raccoglie automazioni e script orchestrati ad alto livello.
mirai/ ospita runtime e asset personalizzati del progetto Mirai.
lovelace/ conserva le dashboard YAML; docs/ e tools/ restano solo locali.
ops/ include gli script di manutenzione: usa ops/synch_ha.ps1 per sincronizzare verso Z:\config.
Lo script copia solo packages, mirai, logica e lovelace in modalità mirror con esclusioni temporanee.
Per dettagli tecnici e note climatizzazione leggi README_ClimaSystem.md.
