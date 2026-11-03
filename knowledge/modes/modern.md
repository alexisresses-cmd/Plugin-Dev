# Mode modern

> Code maintenu, conventions de la stack globalement suivies, tests et outillage en place. Principe : **appliquer la stack telle quelle**.

## analyse
- Analyse standard : s'appuyer sur la structure du framework et les précédents du projet.

## plan
- Découpage standard ; une tâche de tests par comportement nouveau.

## implement
- Conventions de la stack et de `.devflow/conventions.md`.
- Suivre le précédent le plus proche dans le projet (fichier de référence cité dans l'analyse).

## test
- Tests unitaires et fonctionnels avec le framework détecté (`tooling.test`).
- Tout comportement nouveau ou corrigé est couvert par au moins un test automatisé.

## review
- Revue **complète** : qualité, bugs, sécurité, conventions de la stack.

## simplifier
- Normal : réduire le diff et simplifier le nouveau code ; ne pas toucher au code existant hors diff.

## gates
- Seuils standards : tests verts, lint et analyse statique sans erreur nouvelle sur les fichiers modifiés (baseline acceptée si elle existe).

## pr
- Description standard (contexte, changements, comment tester, points d'attention).
