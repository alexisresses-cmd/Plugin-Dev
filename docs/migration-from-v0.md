# Migration depuis la v0 (ai-claude-php-workflow)

> La v0 s'installait par `install.sh`, qui copiait skills, workflows et commandes dans `~/.claude/` et fusionnait des règles `deny` dans `~/.claude/settings.json`. devflow v1 est un plugin installé par la marketplace : plus rien n'est copié dans `~/.claude/`.
> Correspondance détaillée des fichiers : [source-inventory.md](source-inventory.md).

## 1. Installer le plugin

```bash
/plugin marketplace add alexisresses-cmd/Plugin-Dev
/plugin install devflow@alexis-plugins
```

`update.sh` n'a plus d'équivalent : `/plugin marketplace update alexis-plugins`.

## 2. Supprimer les fichiers de la v0

Les skills v0 restent sinon actifs sous leur ancien nom (`/dev-analyse`…) à côté de ceux du plugin, et Claude peut déclencher l'ancienne version. Commandes à lancer **vous-même** dans un terminal, après avoir vérifié avec `ls` que les dossiers ne contiennent rien que vous ayez ajouté.

Skills (les prompts d'agents de la v0 étaient dans `skills/*/agents/` : ils partent avec leur dossier) :

```bash
rm -r ~/.claude/skills/_shared
rm -r ~/.claude/skills/dev-analyse
rm -r ~/.claude/skills/dev-plan
rm -r ~/.claude/skills/dev-cycle
rm -r ~/.claude/skills/dev-implement
rm -r ~/.claude/skills/dev-test
rm -r ~/.claude/skills/dev-review
rm -r ~/.claude/skills/challenge-review
rm -r ~/.claude/skills/dev-pr
rm -r ~/.claude/skills/review-return
```

Workflows et commandes :

```bash
rm ~/.claude/workflows/dev-cycle.js
rm ~/.claude/workflows/dev-review.js
rm ~/.claude/commands/dev-branch.md
rm ~/.claude/commands/dev-commit.md
```

Sauvegardes : `install.sh --force` laissait un `<fichier>.bak` à côté de chaque fichier remplacé, et la fusion de la configuration un `~/.claude/settings.json.bak`. Repérez-les avec `find ~/.claude/skills ~/.claude/workflows ~/.claude/commands -name '*.bak'` et supprimez-les de la même façon.

`~/.claude/settings.json` : la v0 y avait ajouté trois règles `deny` (`Bash(rm:-rf*)`, `Bash(rm:-f*)`, `Bash(git:push --force*)`). Le hook `block-dangerous.sh` du plugin les remplace ; vous pouvez les retirer ou les garder (sans conflit).

Agents et hooks : `install.sh` n'en installait pas. Si vous aviez ajouté à la main l'agent `dev-simplifier`, un skill `dev-copilot` ou un hook anti-commentaires dans `~/.claude/`, retirez-les : le plugin les fournit (agent `devflow:dev-simplifier`, skill `/devflow:dev-copilot`, hook activé par `hooks.no_comments: true`).

## 3. Correspondance des commandes

| v0 | v1 |
|---|---|
| `/dev-analyse {ticket}` | `/devflow:dev-analyse {ticket}` |
| `/dev-plan` | `/devflow:dev-plan` |
| `/dev-cycle {analyse}` (mode Automated) | `/devflow:dev-cycle {analyse}` |
| Mode Orchestra (un contexte par phase) | `/devflow:dev-cycle {analyse} --checkpoints` (ou `pipeline.checkpoints: true`) |
| Mode séquentiel | `/devflow:dev-implement` → `/devflow:dev-test` → `/devflow:dev-review` → `/devflow:dev-pr` |
| `/challenge-review` | `/devflow:challenge-review` |
| `/review-return {pr}` | `/devflow:review-return {pr}` |
| `/dev-branch {id}` | `/devflow:dev-branch {id}` |
| `/dev-commit` | `/devflow:dev-commit` (skill, aussi appelé par les autres skills) |
| — | `/devflow:init`, `/devflow:discover`, `/devflow:rules`, `/devflow:dev-copilot` |

## 4. Configuration du projet

Lancez `/devflow:init` dans chaque projet. Il reprend comme propositions les clés v0 du `CLAUDE.md` :

| Clé v0 (`CLAUDE.md`) | Clé v1 (`.devflow/config.yml`) |
|---|---|
| `BRANCH_PREFIX` | `git.branch_prefix` |
| `COMMIT_FORMAT` | `git.commit_format` |
| `ISSUE_TRACKER` | `issue_tracker` |
| `MAIN_REVIEWER` | `git.main_reviewer` |

Il recopie la section « Conventions spécifiques au projet » dans `.devflow/conventions.md`, ajoute une section `## devflow` à la fin du `CLAUDE.md` sans rien supprimer, et signale les anciennes clés, que vous pouvez ensuite retirer. Les sections « Identité », « Stack technique » et préférences personnelles ne sont plus lues par les skills : la stack est détectée, les préférences vont dans `.devflow/config.local.yml`.

Projet legacy : enchaînez avec `/devflow:discover` (carte du projet et conventions observées).

## 5. Ruptures

- **Configuration obligatoire** : sans `.devflow/config.yml`, les skills s'arrêtent et demandent `/devflow:init`. Les skills ne lisent plus `CLAUDE.md`.
- **Plus de mode Orchestra ni de workflows JS** (`dev-cycle.js`, `dev-review.js`) : `dev-cycle` est un skill qui lance les agents, avec `--checkpoints` pour valider entre les phases.
- **Gates renumérotées** : G0 (tests de caractérisation avant un refactor, nouvelle), G1 (implémentation), G2 (revue). La G3 de la v0 disparaît. Les gates sont évaluées par l'agent `gate-checker`, plus par l'agent qui a écrit le code.
- **Fichier d'analyse** : même emplacement (`analysis/YYYYMMDD-slug.md`) mais un en-tête YAML (`task_type`, `size`, `security_audit`, `status`). Pour un ticket en cours démarré en v0, relancez `/devflow:dev-analyse` puis `/devflow:dev-plan`.
- **Triage S/M/L** : un ticket `S` passe par la voie rapide (implémentation → G1 → PR) ; les planners ne sont lancés que pour un ticket `L`.
- **Tests** : `dev-test` utilise le framework du projet (`tooling.test`, ex. PHPUnit) ; les scripts PHP sans framework ne sont plus qu'un repli quand `tooling.test` vaut `null`.
- **Revue** : sévérités `blocking` / `should-fix` / `note` (au lieu de `to_fix`), findings challengés par `review-challenger` avant G2. Les reviewers ne peuvent lancer que des commandes git de lecture.
- **Branche principale** : lue dans `git.base_branch` (plus de `main` codé en dur).
- **Hook anti-commentaires** : désactivé par défaut ; à activer dans `config.local.yml` (`hooks.no_comments: true`).
- **Préférences personnelles de `settings.json`** (`theme`, `effortLevel`, `skipWorkflowUsageWarning`) : hors du plugin, à gérer dans votre propre configuration.

Détail par version : [CHANGELOG](../CHANGELOG.md).
