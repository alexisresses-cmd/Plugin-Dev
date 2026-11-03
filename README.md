# devflow

> Plugin Claude Code multi-stack : de l'analyse du ticket à la PR, avec des agents qui adaptent leurs règles à la stack, à la maturité du projet et au type de tâche.

**Statut :** v1.0.0. Stacks PHP (natif, Symfony, WordPress) et TypeScript (Node, NestJS, Angular), projets mixtes ; modes `legacy`, `modern`, `greenfield` ; types de tâche `feature`, `bugfix`, `refactor`.

## Installation

```bash
/plugin marketplace add alexisresses-cmd/Plugin-Dev
/plugin install devflow@alexis-plugins
```

En local, depuis un clone : `/plugin marketplace add ./` puis `/plugin install devflow@alexis-plugins`. Mise à jour : `/plugin marketplace update alexis-plugins`.

Vous utilisiez la v0 (`ai-claude-php-workflow` et son `install.sh`) : suivez le [guide de migration](docs/migration-from-v0.md).

## Démarrage

```bash
/devflow:init                                                 # qualifie le projet → .devflow/config.yml (obligatoire)
/devflow:discover                                             # projet legacy : carte du projet + conventions observées
/devflow:dev-analyse https://github.com/owner/repo/issues/42   # triage S/M/L + agents d'analyse → analysis/YYYYMMDD-slug.md
/devflow:dev-plan                                             # plan challengé et validé, branche, draft PR, mode recommandé
/devflow:dev-cycle analysis/20261102-mon-ticket.md            # implémentation → G1 → tests → revue → G2 → PR
/devflow:dev-cycle analysis/20261102-mon-ticket.md --checkpoints  # même chose, avec validation entre chaque phase
```

Pas à pas, dans la même conversation : `/devflow:dev-implement` → `/devflow:dev-test` → `/devflow:dev-review` → `/devflow:dev-pr`.
Après la PR : `/devflow:review-return` (retours du reviewer principal), `/devflow:dev-copilot` (retours de Copilot), `/devflow:challenge-review` (challenge d'une revue).

## Trois axes

Les agents sont les mêmes pour toutes les combinaisons ; seules les règles qu'ils chargent changent (`knowledge/RESOLVER.md`).

| Axe | Valeurs | Fixé dans |
|---|---|---|
| Stack | `php-native`, `symfony`, `wordpress`, `typescript`, `node`, `nestjs`, `angular` | `.devflow/config.yml` (un bloc par sous-projet) |
| Mode de maturité | `legacy`, `modern`, `greenfield` | `.devflow/config.yml` (par bloc) |
| Type de tâche | `feature`, `bugfix`, `refactor` | en-tête du fichier `analysis/*.md` (triage) |

| Mode | Pour quel projet | Comportement |
|---|---|---|
| `legacy` | code ancien, peu ou pas testé | part de la carte du projet ; imite les conventions observées ; changement minimal ; tests de caractérisation d'abord ; la revue juge le diff seul ; règle du cliquet (ne pas aggraver l'analyse statique) |
| `modern` | projet outillé et testé | conventions de la stack, tests unitaires du framework, revue complète, seuils standards |
| `greenfield` | projet neuf (moins de 5 fichiers source) | stack idéale à la lettre, outillage et ADR dès le départ, tests à chaque tâche, revue stricte |

Ordre de priorité des règles, du plus fort au plus faible : `.devflow/conventions.md` → contrat d'API (projet mixte) → type de tâche → mode → profil de stack (enfant puis parent) → `core/clean-code.md`.

## Stacks supportées

| Profil | Étend | Détection par `/devflow:init` |
|---|---|---|
| `php-native` | — | `composer.json` ou `index.php` (PHP sans framework reconnu) |
| `symfony` | `php-native` | `symfony.lock`, `bin/console`, `config/bundles.php` ; paquet `symfony/framework-bundle` |
| `wordpress` | `php-native` | `wp-config.php`, `wp-load.php` ; paquets `johnpbloch/wordpress`, `roots/wordpress`, `wp-coding-standards/wpcs` ; en-tête `Theme Name:` (`style.css`) ou `Plugin Name:` (`*.php`) |
| `typescript` | — | `tsconfig.json` ; paquet `typescript` |
| `node` | `typescript` | paquets `express`, `fastify`, `koa`, `@hapi/hapi` |
| `nestjs` | `node` | `nest-cli.json` ; paquet `@nestjs/core` |
| `angular` | `typescript` | `angular.json` ; paquet `@angular/core` |

Le profil le plus profond de la chaîne `extends` l'emporte (`@nestjs/core` → `nestjs` même si `express` est présent). WordPress : `/devflow:init` détecte aussi le type (thème, thème enfant, extension, mu-plugin, site) et les chemins protégés (cœur, thème parent, extensions tierces), qu'un hook rend non modifiables. Laravel et AngularJS 1.x sont hors périmètre. Pour ajouter une stack : [docs/adding-a-stack.md](docs/adding-a-stack.md).

## Projets mixtes

Un bloc `stacks[]` par sous-projet ; chaque fichier relève du `path` le plus long qui le contient, et chaque agent applique à un fichier les règles de son bloc.

```yaml
stacks:
  - path: api/
    profile: symfony
    mode: modern
  - path: front/
    profile: angular
    mode: legacy
tooling:
  test: "(cd api && vendor/bin/phpunit) && (cd front && npx vitest run)"
```

Règle du contrat d'API : un ticket qui change un contrat (route, DTO, schéma) met à jour **les deux côtés dans le même ticket**, dans l'ordre contrat → serveur → client. Un ticket qui touche plusieurs blocs est de taille L.

## Triage, voie rapide et gates

- **Triage** (`dev-analyse`) : type de tâche, besoin d'audit sécurité et taille. `S` : 1 ou 2 fichiers, ni schéma ni API, correction évidente ; `L` : plus de 8 fichiers, plusieurs sous-projets, contrat ou schéma partagé ; `M` sinon. `S` n'interroge que `code-mapper` ; `L` ajoute les planners au plan.
- **Voie rapide** (taille `S`, `pipeline.fast_lane: true`) : implémentation → G1 → PR.
- **Gates**, évaluées par l'agent `gate-checker` (2 corrections automatiques maximum, puis arrêt) :
  - **G0** (refactor) : tests de caractérisation écrits et verts avant toute modification de production ;
  - **G1** (après implémentation) : plan couvert, lint, analyse statique, pas de code de debug, format des commits, pas de fichier hors périmètre ;
  - **G2** (après revue challengée) : aucun finding bloquant, tests et analyse statique verts.

## Réglages recommandés

Préférences personnelles dans `.devflow/config.local.yml` (gitignoré, fusionné par-dessus `config.yml`) :

```yaml
pipeline:
  simplifier: true      # passe dev-simplifier après l'implémentation
hooks:
  no_comments: true     # signale les commentaires superflus
```

Un plugin ne peut pas déclarer de permissions. Pour éviter les demandes répétées, autorisez dans `.claude/settings.json` du projet les commandes de lecture et celles de `tooling`, par exemple :

```json
{
  "permissions": {
    "allow": [
      "Bash(git diff:*)", "Bash(git log:*)", "Bash(git status:*)",
      "Bash(gh issue view:*)", "Bash(gh pr view:*)",
      "Bash(vendor/bin/phpunit:*)", "Bash(npx vitest run:*)"
    ]
  }
}
```

Les règles de blocage (secrets, `rm -rf`, `git push --force`, base de production) sont portées par les hooks du plugin.

Les conventions observées du projet vont dans `.devflow/conventions.md` et priment sur les règles génériques. Pour voir ce qu'un agent charge : `/devflow:rules reviewer-quality src/Controller/ProductController.php`.

## Contenu

| Type | Éléments |
|---|---|
| Skills (orchestrateurs) | `dev-analyse`, `dev-plan`, `dev-cycle`, `dev-implement`, `dev-test`, `dev-review`, `challenge-review`, `dev-pr`, `dev-commit`, `review-return`, `dev-copilot`, `rules` |
| Commandes | `init`, `discover`, `dev-branch` |
| Agents (contexte isolé) | analyse : `business-analyst`, `code-mapper`, `architect`, `security-analyst` · plan : `plan-challenger`, `planner-dev`, `planner-cto` · tests : `test-writer` · revue : `reviewer-quality`, `reviewer-bugs`, `reviewer-security`, `review-challenger` · gates : `gate-checker` · découverte : `cartographer`, `convention-detector`, `risk-mapper` · `dev-simplifier` |
| Hooks | blocage des secrets, des commandes dangereuses, protection des chemins WordPress, lecture seule pour les agents de revue, signalement des commentaires superflus |
| Règles | `knowledge/` : 7 profils de stack, 3 modes, 3 types de tâche, principes génériques, contrat d'API |

## Évals

Tickets de référence et cases exécutables par `claude plugin eval` (fixtures statiques, graders) : voir [evals/README.md](evals/README.md). La CI (`.github/workflows/ci.yml`) valide le plugin et teste les hooks à chaque push ; les évals (`evals.yml`) se lancent à la main et exigent le secret de dépôt `ANTHROPIC_API_KEY` (appels facturés).

## Documentation

- [Spécification](docs/SPEC.md) et [décisions d'architecture](docs/adr/)
- [Ajouter une stack](docs/adding-a-stack.md)
- [Migration depuis la v0](docs/migration-from-v0.md)
- [Procédure de chargement des règles](knowledge/RESOLVER.md)
- [Modèle de configuration](templates/config.yml)
- [Historique des versions](CHANGELOG.md)

Ce plugin est la refonte de [ai-claude-php-workflow](https://github.com/alexisresses-cmd/ai-claude-php-workflow), conservé comme archive.

## Licence

MIT
