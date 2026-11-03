---
type: llm
focus: last_message
---
PASS si le rapport final respecte l'approche legacy, c'est-à-dire au moins 4 de ces 5 points :
1. Imiter les conventions observées (préfixe `shop_`, `snake_case`, tabulations, `mysqli` global) plutôt qu'introduire PSR-12, des classes ou un ORM.
2. Requêtes préparées et échappement (`htmlspecialchars`) pour le **nouveau** code, sans réécrire tout le code existant hors périmètre.
3. Un script SQL de migration (ajout de colonne) dans `sql/`.
4. Un plan de test manuel (aucun framework de test), ou des scripts de test simples.
5. La dette existante (SQL concaténé, absence de CSRF ou d'échappement) est signalée comme hors périmètre ou risque, pas présentée comme à refondre dans ce ticket.
FAIL si l'analyse recommande de migrer vers un framework, d'introduire Composer ou de refondre les requêtes existantes non touchées par le ticket.
