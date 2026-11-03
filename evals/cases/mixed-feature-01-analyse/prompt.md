---
runs: 1
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Agent, Write]
expected_outcome: "Analyse qui liste les profils symfony et angular, identifie le contrat d'API (ProductInput/ProductOutput PHP, product.ts) et exige la validation serveur."
---
/devflow:dev-analyse #58 — Ajouter un champ `stock` (entier ≥ 0) au produit : saisie dans le formulaire d'administration Angular, persistance et validation côté API, affichage « Rupture » quand `stock = 0`.
