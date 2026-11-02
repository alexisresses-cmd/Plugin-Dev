---
type: llm
focus: last_message
---
PASS si toutes ces conditions sont vraies dans le rapport :
1. Le fichier est associé au profil `symfony` en mode `modern`, avec la chaîne d'héritage `symfony` → `php-native`.
2. La section de profil lue est `Conventions` (pour symfony et php-native), et aucune autre section de profil n'est listée comme lue.
3. Les sections `review` de `modes/modern.md` et de `tasks/feature.md` sont listées (type de tâche par défaut : feature).
4. `.devflow/conventions.md` est lu et `core/clean-code.md` est lu.
FAIL sinon.
