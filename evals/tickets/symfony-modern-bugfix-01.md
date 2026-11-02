---
id: symfony-modern-bugfix-01
project: fixture:symfony-api
profile: symfony
mode: modern
task_type: bugfix
size: M
milestone: M1
---
## Projet témoin
Identique à `symfony-modern-feature-01`. `OrderTotalCalculator` calcule le total d'une commande avec remise en pourcentage.

## Ticket
#57 — Le total d'une commande est faux de 1 centime sur certaines remises (ex. 3 articles à 19,99 € avec 15 % de remise : 50,97 € attendu, 50,98 € affiché). Le calcul se fait en `float`.

## Critères attendus
- [ ] Analyse : cause identifiée (arrondi flottant) et périmètre borné à `OrderTotalCalculator`.
- [ ] Un test qui reproduit le bug est écrit **avant** le correctif et échoue sur le code initial.
- [ ] Correctif minimal (calcul en centimes entiers ou `bcmath`), sans refactoring hors périmètre.
- [ ] Description de PR : cause + correctif.
