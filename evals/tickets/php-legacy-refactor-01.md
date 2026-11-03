---
id: php-legacy-refactor-01
project: fixture:php-legacy-shop
profile: php-native
mode: legacy
task_type: refactor
size: M
milestone: M3
---
## Projet témoin
Identique à `php-legacy-feature-01`. Le calcul des frais de port est dupliqué dans `cart.php`, `checkout.php` et `admin/order_edit.php`, avec un écart subtil dans `admin/order_edit.php` (seuil de gratuité `>` au lieu de `>=`).

## Ticket
Centraliser le calcul des frais de port dans une seule fonction réutilisée par les trois écrans.

## Critères attendus
- [ ] Gate G0 : tests de caractérisation (scripts PHP sans framework) écrits **avant** toute modification et verts sur le code initial.
- [ ] Petites étapes réversibles : une transformation par commit, tests verts à chaque commit.
- [ ] L'écart `>` / `>=` est **signalé** (proposition de ticket séparé) et non corrigé ; le comportement de chaque écran est conservé.
- [ ] `reviewer-bugs` conclut à l'équivalence de comportement.
- [ ] PR : avant / après + preuve d'équivalence.
