---
type: llm
focus: last_message
---
PASS si toutes ces conditions sont vraies dans le rapport :
1. Profil `symfony` (mode `modern`) avec héritage de `php-native`.
2. Type de tâche `bugfix`, lu dans le fichier d'analyse.
3. Sections de profil lues : `Testing` et `Tooling` uniquement ; sections `gates` de `modes/modern.md` et `tasks/bugfix.md`.
4. Parmi les règles déterminantes figure l'exigence d'un test de reproduction du bug dans le diff.
FAIL sinon.
