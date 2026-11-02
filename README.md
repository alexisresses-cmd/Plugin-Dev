# devflow

> Plugin Claude Code multi-stack : de l'analyse du ticket à la PR, avec des agents qui adaptent leurs règles à la stack, à la maturité du projet et au type de tâche.

**Statut :** v0.2.0 (jalon M2). Périmètre PHP, avec des agents spécialisés qui travaillent chacun dans leur propre contexte. Le multi-stack arrive aux jalons M3 à M5.

## Installation

```bash
/plugin marketplace add alexisresses-cmd/Plugin-Dev
/plugin install devflow@alexis-plugins
```

En local, depuis un clone : `/plugin marketplace add ./` puis `/plugin install devflow@alexis-plugins`.

## Démarrage

```bash
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
| Commande | `dev-branch` |
| Agents (contexte isolé) | analyse : `business-analyst`, `code-mapper`, `architect`, `security-analyst` · plan : `plan-challenger` (+ `planner-dev`, `planner-cto` pour les tickets lourds) · tests : `test-writer` · revue : `reviewer-quality`, `reviewer-bugs`, `reviewer-security`, `review-challenger` · gates : `gate-checker` · `dev-simplifier` |
| Hooks | blocage des secrets, blocage des commandes dangereuses, lecture seule pour les agents de revue, signalement des commentaires superflus |

La configuration du projet se lit dans son `CLAUDE.md` (`BRANCH_PREFIX`, `COMMIT_FORMAT`, `ISSUE_TRACKER`, `MAIN_REVIEWER`), comme en v0. Elle passera dans `.devflow/config.yml` au M3.

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
