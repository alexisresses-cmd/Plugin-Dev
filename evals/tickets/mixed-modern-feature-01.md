---
id: mixed-modern-feature-01
project: fixture:mixed-angular-symfony
profile: angular+symfony
mode: modern
task_type: feature
size: L
milestone: M5
---
## Projet témoin
Monorepo : `api/` (Symfony 7, profil `symfony`) et `front/` (Angular 19, profil `angular`). Le contrat est partagé via des DTO PHP et des interfaces TypeScript.

## Ticket
Ajouter un champ `stock` (entier ≥ 0) au produit : saisie dans le formulaire d'administration Angular, persistance et validation côté API, affichage « Rupture » quand `stock = 0`.

## Critères attendus
- [ ] `analysis/*.md` liste les deux profils ; chaque agent charge le profil correspondant au fichier traité.
- [ ] Contrat d'API mis à jour **des deux côtés dans le même ticket** (DTO PHP + interface TS).
- [ ] Validation côté serveur (contrainte Symfony) ; la validation front ne la remplace pas.
- [ ] Migration Doctrine ; tests WebTestCase + Vitest.
- [ ] La review signale toute divergence de contrat.
