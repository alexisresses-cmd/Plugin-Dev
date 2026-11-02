---
type: llm
focus: last_message
---
PASS si toutes ces conditions sont vraies dans le rapport :
1. `cart.php` est associé au profil `php-native` en mode `legacy`, sans profil parent.
2. Le type de tâche est `refactor`, lu dans le fichier d'analyse.
3. La section de profil lue est `Testing` ; les sections `test` de `modes/legacy.md` et `tasks/refactor.md` sont listées.
4. Parmi les règles déterminantes figurent les tests de caractérisation écrits avant toute modification, et le repli « sans framework » (scripts PHP ou plan manuel), puisque `tooling.test` est null.
5. `core/clean-code.md` n'est pas lu.
FAIL sinon.
