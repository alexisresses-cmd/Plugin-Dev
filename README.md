# devflow

> Plugin Claude Code multi-stack : de l'analyse du ticket à la PR, avec des agents qui adaptent leurs règles à la stack, à la maturité du projet et au type de tâche.

**Statut :** v0.4.0 (jalon M4). Profils `php-native`, `symfony` et `wordpress` ; modes `legacy`, `modern`, `greenfield` ; types de tâche `feature`, `bugfix`, `refactor`. TypeScript (Node, NestJS, Angular) arrive au M5.

## Installation

```bash
/plugin marketplace add alexisresses-cmd/Plugin-Dev
/plugin install devflow@alexis-plugins
```

En local, depuis un clone : `/plugin marketplace add ./` puis `/plugin install devflow@alexis-plugins`.

## Démarrage

```bash
/devflow:init                                                 # qualifie le projet → .devflow/config.yml
/devflow:discover                                             # projet existant : carte du projet + conventions observées
/devflow:dev-analyse https://github.com/owner/repo/issues/42   # analyse multi-agents
/devflow:dev-plan                                             # plan, branche, draft PR, mode recommandé
/devflow:dev-cycle analysis/20261102-mon-ticket.md            # mode automatisé
/devflow:dev-cycle analysis/20261102-mon-ticket.md --checkpoints  # validation entre chaque phase
```

Mode séquentiel : `/devflow:dev-implement` → `/devflow:dev-test` → `/devflow:dev-review` → `/devflow:dev-pr`.

## Contenu

| Type | Éléments |
|---|---|
| Skills (orchestrateurs) | `dev-analyse`, `dev-plan`, `dev-cycle`, `dev-implement`, `dev-test`, `dev-review`, `challenge-review`, `dev-pr`, `dev-commit`, `review-return`, `dev-copilot` |
| Commandes | `init`, `discover`, `dev-branch`, `rules` (skill de diagnostic) |
| Agents (contexte isolé) | analyse : `business-analyst`, `code-mapper`, `architect`, `security-analyst` · plan : `plan-challenger` (+ `planner-dev`, `planner-cto` pour les tickets lourds) · tests : `test-writer` · revue : `reviewer-quality`, `reviewer-bugs`, `reviewer-security`, `review-challenger` · gates : `gate-checker` · découverte : `cartographer`, `convention-detector`, `risk-mapper` · `dev-simplifier` |
| Hooks | blocage des secrets, blocage des commandes dangereuses, protection des chemins (cœur WordPress, thème parent, extensions tierces), lecture seule pour les agents de revue, signalement des commentaires superflus |

## Configuration

`/devflow:init` détecte les profils, l'outillage et le mode de chaque sous-projet, puis écrit `.devflow/config.yml` (commité). Les préférences personnelles vont dans `.devflow/config.local.yml` (gitignoré), par exemple :

```yaml
pipeline:
  simplifier: true
hooks:
  no_comments: true
```

Les conventions observées du projet vont dans `.devflow/conventions.md` : elles priment sur les règles génériques. Pour voir ce qu'un agent charge : `/devflow:rules reviewer-quality src/Controller/ProductController.php`.

## Stacks visées (v1)

PHP natif, Symfony, WordPress, TypeScript, Node (Express/Fastify), NestJS, Angular.

## Historique

Ce plugin est la refonte de [ai-claude-php-workflow](https://github.com/alexisresses-cmd/ai-claude-php-workflow), le pipeline PHP d'origine, qui est conservé comme archive.

## Documentation

- [Spécification](docs/SPEC.md)
- [Décisions d'architecture](docs/adr/)
- [Inventaire du repo v0](docs/source-inventory.md)
- [Tickets de référence](evals/README.md)

## Licence

MIT
