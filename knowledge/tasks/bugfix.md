# Type de tâche : bugfix

## analyse
- **Cause** du bug (localisée dans le code, avec preuve), conditions de reproduction, **périmètre** exact.
- Recommandation : le **correctif minimal** qui supprime la cause, sans changer les signatures publiques. Toute refonte plus large va dans « Hors périmètre ».

## plan
- Première tâche : un test qui **reproduit le bug** (il doit échouer sur le code actuel). Puis le correctif minimal.

## implement
- Correction ciblée : ne toucher que ce qui est nécessaire pour supprimer la cause.

## test
- Le test de reproduction est écrit **avant** le correctif et échoue sur le code initial ; il passe après.
- Ajouter les cas voisins du bug (bornes, valeurs proches).

## review
- Le bug est-il réellement corrigé (le test le prouve-t-il) ? Rien d'autre n'est-il cassé ? Signaler tout changement hors cause.

## simplifier
- Réduire le diff.

## gates
- G1, puis G2. G1 vérifie en plus qu'un test de reproduction existe dans le diff.

## pr
- **Cause** et **correctif**, en deux paragraphes ; lien vers le test de reproduction.
