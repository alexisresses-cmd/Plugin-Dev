---
type: llm
focus: last_message
---
PASS si toutes ces conditions sont vraies :
1. La première tâche consiste à écrire des tests de caractérisation (gate G0) avant toute modification du code de production.
2. Le plan procède par petites étapes réversibles (au moins 3 tâches, une transformation par tâche).
3. L'écart `>` / `>=` du back-office est **préservé** (aucune tâche ne l'aligne) et signalé comme ticket séparé.
4. La nouvelle fonction suit la convention `shop_` + `snake_case` dans `includes/functions.php`.
5. Le plan est présenté pour validation, sans branche ni PR annoncée comme créée.
FAIL sinon.
