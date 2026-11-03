---
id: symfony-modern-fastlane-01
project: fixture:symfony-api
profile: symfony
mode: modern
task_type: bugfix
size: S
milestone: M3
---
## Projet témoin
Identique à `symfony-modern-feature-01`.

## Ticket
#61 — Faute de frappe dans le message de validation de `Product::$name` : « Le nom est obligatoir ».

## Critères attendus
- [ ] Triage : taille **S**, voie rapide proposée (`pipeline.fast_lane: true`).
- [ ] Chemin effectif : implement → G1 → dev-commit → dev-pr (pas de planners ni de reviewers multiples).
- [ ] Un seul fichier modifié (plus le fichier de traduction si le message y est défini).
- [ ] Tokens consommés nettement inférieurs à `symfony-modern-bugfix-01`.
