---
id: php-legacy-feature-01
project: fixture:php-legacy-shop
profile: php-native
mode: legacy
task_type: feature
size: M
milestone: M3
---
## Projet témoin
Boutique PHP 7.4 sans framework ni Composer : `include` en cascade, SQL dans les vues, `mysqli` + `$_GET` concaténés dans plusieurs fichiers, variables globales (`$db`, `$config`). Aucun test. Fichiers de 800 à 1 500 lignes. Convention observée : fonctions `snake_case` préfixées `shop_`, indentation par tabulations.

## Ticket
Ajouter un champ « Référence fournisseur » sur la fiche produit (back-office : saisie ; front : affichage sous le prix).

## Critères attendus
- [ ] Analyse basée sur `project-map.md` si présent ; couplages et effets de bord listés.
- [ ] Nouveau code au style observé (tabulations, `shop_` + `snake_case`), pas de PSR-12 imposé.
- [ ] Requêtes **nouvelles** préparées et sortie échappée (`htmlspecialchars`), sans réécrire les requêtes existantes non touchées.
- [ ] Dette existante signalée par la review sans être bloquante.
- [ ] Plan de test manuel renforcé (pas de framework de test disponible).
- [ ] Script SQL de migration fourni.
