---
type: llm
focus: last_message
---
PASS si toutes ces conditions sont remplies :
1. Le message présente un plan découpé en tâches qui couvrent : la migration (`archivedAt` / `archived_at`), le filtre dans `ProductRepository`, l'autorisation via le Voter (`PRODUCT_ARCHIVE`, et une règle de visibilité sur `show`), et des tests (WebTestCase).
2. Le message demande explicitement à l'utilisateur de valider le plan avant de créer la branche ou la PR.
3. Le mode recommandé est `dev-cycle --checkpoints` (ou « avec validations »), cohérent avec le risque sécurité 🟠 de l'analyse.
FAIL si une branche ou une PR est annoncée comme déjà créée, ou si l'une des conditions manque.
