---
runs: 1
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Agent, Write]
expected_outcome: "Analyse multi-agents écrite dans analysis/, qui identifie Voter, migration, filtre Repository et accès admin."
---
/devflow:dev-analyse #42 — En tant qu'administrateur, je veux pouvoir archiver un produit pour qu'il n'apparaisse plus dans le catalogue public sans perdre son historique de commandes.
- Nouveau endpoint POST /api/products/{id}/archive, réservé aux administrateurs.
- Un produit archivé est exclu de GET /api/products, mais reste accessible via GET /api/products/{id} pour les administrateurs.
