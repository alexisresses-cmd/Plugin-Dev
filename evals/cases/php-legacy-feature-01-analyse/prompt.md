---
runs: 1
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Agent, Write]
expected_outcome: "Analyse legacy : conventions observées, requêtes préparées pour le nouveau code seulement, script SQL, plan de test manuel, dette signalée."
---
/devflow:dev-analyse Ajouter un champ « Référence fournisseur » sur la fiche produit (back-office : saisie dans admin/product_edit.php ; front : affichage sous le prix dans product.php).
