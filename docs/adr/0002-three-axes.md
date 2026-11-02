# ADR 0002 — Trois axes indépendants : stack, maturité, type de tâche

- **Statut :** accepté
- **Date :** 2026-11-02
- **Réf. SPEC :** D1, D2

## Contexte

Le pipeline v0 est écrit pour PHP : les règles de stack sont mêlées aux prompts. Ajouter Symfony, WordPress, Angular ou NestJS en recopiant les prompts multiplierait les variantes (7 stacks × 3 maturités × 3 types = 63 combinaisons).

## Décision

Le comportement des agents dépend de trois axes indépendants :

| Axe | Valeurs v1 | Porté par | Stocké dans |
|---|---|---|---|
| Stack | `php-native`, `symfony`, `wordpress`, `typescript`, `node`, `nestjs`, `angular` | le dossier du projet | `.devflow/config.yml` |
| Maturité | `legacy`, `modern`, `greenfield` | le dossier du projet | `.devflow/config.yml` |
| Type de tâche | `feature`, `bugfix`, `refactor` | le ticket | `analysis/*.md` (`task_type`) |

Les **agents sont uniques** ; seules les **règles chargées** varient. Chaque axe est un fichier de connaissances (`knowledge/stacks|modes|tasks/*.md`) découpé en sections par phase ou par agent. En cas de conflit, la priorité est (du plus fort au plus faible) : `conventions.md` du projet > type de tâche > mode > stack > `core`.

## Conséquences

- On obtient 7 + 3 + 3 = 13 fichiers au lieu de 63 variantes.
- En legacy, les conventions observées dans le projet priment sur les conventions idéales de la stack.
- Un nouvel axe (ex. type de tâche `upgrade`) n'ajoute qu'un fichier, sans toucher aux agents.
- Coût : chaque agent applique une procédure de résolution (ADR 0003, `RESOLVER.md`) qui doit rester économe en tokens.
