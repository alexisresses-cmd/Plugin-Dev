# Inventaire du repo source

> Source : [ai-claude-php-workflow](https://github.com/alexisresses-cmd/ai-claude-php-workflow), cloné en lecture seule dans `_source/`.
> Pour chaque fichier : destination dans la nouvelle structure, jalon de migration et passages spécifiques à PHP à généraliser.

Légende des destinations : **skill** · **agent** · **knowledge** · **hook** · **template** · **doc** · **supprimé**.

## 1. Vue d'ensemble

| Fichier source | Destination | Jalon | Remarques |
|---|---|---|---|
| `skills/dev-analyse/SKILL.md` | skill `skills/dev-analyse/` | M1 → M2 | Devient orchestrateur léger en M2 (triage S/M/L en M3) |
| `skills/dev-analyse/agents/business.md` | agent `business-analyst` | M2 | Prompt quasi agnostique |
| `skills/dev-analyse/agents/code.md` | agent `code-mapper` | M2 | Modèle haiku |
| `skills/dev-analyse/agents/architecture.md` | agent `architect` | M2 | Section `## Architecture` des profils |
| `skills/dev-analyse/agents/security.md` | agent `security-analyst` | M2 | Checklist PHP à sortir vers `stacks/*.md` § Security |
| `skills/dev-plan/SKILL.md` | skill `skills/dev-plan/` | M1 → M2 | Grille de recommandation de mode : refondue (3.6, dev-cycle avec/sans checkpoints) |
| `skills/dev-plan/agents/developer.md` | agent `planner-dev` | M2 | |
| `skills/dev-plan/agents/architect.md` | agent `planner-cto` | M2 | Renommé, élargi : arbitrages + mode recommandé |
| `skills/dev-plan/agents/challenger.md` | agent `plan-challenger` | M2 | |
| `skills/dev-cycle/SKILL.md` | skill `skills/dev-cycle/` | M1 → M2 | Réécrit en M2 (3.6) |
| `skills/dev-cycle/workflow.js` | supprimé (M2) / conservé tel quel en M1 | M1 | Voir § 3 « Workflows » |
| `skills/dev-implement/SKILL.md` | skill `skills/dev-implement/` | M1 | Reste un skill. Gate G1 interne → `gate-checker` en M2 |
| `skills/dev-test/SKILL.md` | skill `skills/dev-test/` → agent `test-writer` | M1 → M2 | Approche « scripts PHP sans framework » remplacée par le framework de test du profil (`## Testing`) |
| `skills/dev-test/references/php-test-patterns.md` | knowledge `stacks/php-native.md` § Testing | M3 | Devient le fallback « pas de framework de test » du mode legacy |
| `skills/dev-review/SKILL.md` | skill `skills/dev-review/` | M1 → M2 | Orchestrateur léger |
| `skills/dev-review/workflow.js` | supprimé (M2) / conservé en M1 | M1 | Logique G2 → `gate-checker` + boucle dans `dev-cycle` |
| `skills/dev-review/agents/quality.md` | agent `reviewer-quality` | M2 | Sortie → JSON findings commun |
| `skills/dev-review/agents/bugs.md` | agent `reviewer-bugs` | M2 | + équivalence de comportement (refactor) |
| `skills/dev-review/agents/security.md` | agent `reviewer-security` | M2 | Audit upload PHP → `php-native.md` § Security |
| `skills/challenge-review/SKILL.md` | skill wrapper + agent `review-challenger` | M2 | |
| `skills/challenge-review/references/grille-analyse.md` | référence de l'agent `review-challenger` | M2 | Agnostique, conservé tel quel |
| `skills/challenge-review/references/patterns-bikeshedding.md` | référence de l'agent `review-challenger` | M2 | Agnostique, conservé tel quel |
| `skills/dev-pr/SKILL.md` | skill `skills/dev-pr/` | M1 | Lit `git.main_reviewer` (M3) |
| `skills/review-return/SKILL.md` | skill `skills/review-return/` | M1 | Lit `git.main_reviewer` (M3) |
| `skills/_shared/clean-code.md` | knowledge `core/clean-code.md` | M1 | Exemples PHP à neutraliser (M3) |
| `skills/_shared/php-conventions.md` | knowledge `stacks/php-native.md` | M1 (provisoire) → M3 | Découpé selon les 7 sections du contrat 3.3 |
| `commands/dev-branch.md` | commande `commands/dev-branch.md` | M1 | Lit `git.branch_prefix` (M3) |
| `commands/dev-commit.md` | skill `skills/dev-commit/` | M1 | Passe en skill : invoqué par les autres skills (seul point d'application du format de commit) |
| `settings.json` (`permissions.deny`) | hook `block-dangerous.sh` | M1 | Un plugin ne peut pas déclarer de règles `deny` (ADR 0001) |
| `settings.json` (`theme`, `effortLevel`, `skipWorkflowUsageWarning`) | supprimé | — | Préférences perso, hors plugin |
| `CLAUDE.template.md` | template `templates/config.yml` + `templates/CLAUDE.snippet.md` + `templates/conventions.md` | M3 | Clés → `.devflow/config.yml` ; sections « Conventions spécifiques » → `conventions.md` |
| `install.sh`, `update.sh` | supprimé | M1 | Remplacés par le marketplace (`/plugin install`) |
| `docs/orchestra-mode.md`, `docs/sequential-mode.md` | doc (README § Modes) | M6 | Orchestra = `dev-cycle` + checkpoints |
| `README.md` | doc (README, `migration-from-v0.md`) | M6 | |
| `.gitignore`, `.gitattributes` | repris | M0 | Fait |

## 2. Éléments de la config perso d'Alexis (absents de la source)

Décision M0 : **réécrits** à partir de leur description dans le plan.

| Élément | Destination | Jalon |
|---|---|---|
| `dev-simplifier` | agent `agents/dev-simplifier.md` (+ section `## Simplification` des profils, `## simplifier` des modes / tâches) | M1 |
| Hook anti-commentaires | `hooks/scripts/no-comments.sh` (PostToolUse Edit/Write), activé si `hooks.no_comments: true` | M1 (actif par défaut) → M3 (configurable) |
| `dev-copilot` | skill `skills/dev-copilot/` (traitement des retours Copilot, calqué sur `review-return`) | M1 |

## 3. Constats transverses

### Chemins à corriger (M1)
- `~/.claude/skills/_shared/clean-code.md` → `${CLAUDE_PLUGIN_ROOT}/knowledge/core/clean-code.md` (dans `dev-implement`, `dev-cycle/workflow.js`).
- `agents/*.md` relatifs au skill → agents de plugin `devflow:<nom>` (M2).
- Références aux commandes : `/dev-plan` → `/devflow:dev-plan`, etc. (tous les skills, README, docs).

### Format de commit écrit en dur (à supprimer — règle « tout passe par dev-commit »)
- `dev-implement/SKILL.md` Étape 2 (format Conventional Commits recopié).
- `dev-implement/SKILL.md` Étape 4 : `fix(scope): gate G1 — …`.
- `dev-cycle/workflow.js` : prompt implement (point 5) et correction G1.
- `dev-review/workflow.js` : correction G2 `fix(scope): correction review — …`.

### Clés de `CLAUDE.md` lues par les skills → `.devflow/config.yml` (M3)
| Clé v0 | Clé v1 | Lue par |
|---|---|---|
| `BRANCH_PREFIX` | `git.branch_prefix` | dev-branch, dev-plan, dev-commit |
| `COMMIT_FORMAT` | `git.commit_format` | dev-commit (uniquement) |
| `ISSUE_TRACKER` | `issue_tracker` | dev-analyse |
| `MAIN_REVIEWER` | `git.main_reviewer` | dev-pr, review-return, dev-cycle |

### Branche principale codée en dur
`main` / `master` apparaît dans dev-plan (`--base main`), dev-test, dev-pr, dev-review (`git diff main...HEAD`), challenge-review. → Détection (`git symbolic-ref refs/remotes/origin/HEAD`) ou clé `git.base_branch` (proposée en backlog).

### Workflows (`workflow.js`)
`dev-cycle` et `dev-review` reposent sur l'outil **Workflow** (scripts `.js` installés dans `~/.claude/workflows/`). Les plugins supportent nativement un dossier `workflows/` (ADR 0001). Le plan (D4, 3.6) fait porter l'orchestration par les skills : les workflows sont conservés tels quels en M1 (fonctionnalités égales), puis remplacés en M2. Alternative notée dans `docs/backlog.md`.

### Gates de la source vs plan
La source a **G1** (implémentation, 7 critères), **G2** (tests dans dev-cycle, review dans dev-review — numérotation incohérente) et **G3** (review dans dev-cycle). Le plan normalise : **G0** (caractérisation, refactor), **G1** (implémentation), **G2** (review).

## 4. Passages spécifiques à PHP (à généraliser en M3)

| Fichier | Passage | Destination v1 |
|---|---|---|
| `_shared/clean-code.md` | Titre « (PHP) », exemples `processUpload`, `MAX_UPLOAD_SIZE_BYTES`, checklist `var_dump`/`dd()`/`print_r` | Exemples neutres dans `core/` ; checklist debug → `stacks/*` § Conventions |
| `_shared/php-conventions.md` | Intégralité (PSR-12, PSR-4, PSR-3, sécurité PHP, erreurs, typage) | `stacks/php-native.md` (Conventions, Security, Architecture) |
| `dev-analyse/SKILL.md` | « continuer en mode générique PHP » | Erreur → `/devflow:init` |
| `dev-analyse/agents/security.md` | `htmlspecialchars`, `move_uploaded_file()`, patterns Grep `$_FILES`, `eval(`, `shell_exec` ; « stack PHP du projet » | `stacks/*.md` § Security |
| `dev-analyse/agents/code.md` | Exemples « hooks, observers » | Générique |
| `dev-plan/agents/developer.md` | Ordre « modèle, BDD → vue, contrôleur » | `stacks/*` § Architecture |
| `dev-cycle/workflow.js` | « développeur expert PHP », « expert en test PHP », « script PHP de test (sans framework) » | Profil chargé par le RESOLVER |
| `dev-implement/SKILL.md` | G1 `no_debug_code` → `var_dump`, `dd()` ; `conventions_respected` → PSR-12 | `stacks/*` § Conventions / Tooling |
| `dev-test/SKILL.md` + `references/php-test-patterns.md` | Scripts PHP sans framework, `php tests/test_*.php` | `stacks/*` § Testing ; fallback legacy |
| `dev-review/workflow.js` | « expert PHP » ×3, « expert sécurité PHP » | Profil |
| `dev-review/agents/bugs.md` | « Type PHP vs type BDD » | `stacks/*` § Data & migrations |
| `dev-review/agents/security.md` | Audit upload (`UPLOAD_ERR_OK`, `mime_content_type()`, `uniqid()`) ; « stack PHP » | `php-native.md` § Security |
| `CLAUDE.template.md` | Stack PHP, PSR-12 | `templates/` |

## 5. Comportements à préserver (critère M1 « fonctionnalités égales »)

1. `dev-analyse` : 4 agents en parallèle, sources GitHub / Trello / texte, fichier `analysis/YYYYMMDD-{slug}.md`, feu vert ✅ / ⚠️ / ❌.
2. `dev-plan` : validation explicite avant branche, draft PR, section Plan dans le fichier d'analyse, recommandation de mode.
3. `dev-implement` : modes interactif / `--orchestrator`, bilan JSON, G1 7 critères, règle de dérive de scope (≤ 5 lignes).
4. `dev-test` : tests automatisés + plan manuel (golden path, limites, erreurs, non-régression).
5. `dev-review` : 3 reviewers en parallèle (sécurité en opus), niveaux blocking / to_fix / note, verdict go / go_with_reserves / no_go, correction auto 2× max.
6. `challenge-review` / `review-return` : tableau verdict + sévérité réelle + résumé exécutif ; ne jamais juger sans lire le code.
7. `dev-pr` : description en 5 sections, `gh pr ready`, ajout du reviewer.

## 6. Défauts de la v0 découverts pendant la migration (M1)

| Constat | Impact | Traitement M1 |
|---|---|---|
| `dev-cycle/workflow.js` : apostrophes non échappées dans des chaînes `'…'` (`'Lecture de l'analyse…'`) | **Erreur de syntaxe JS** : le workflow ne pouvait pas s'exécuter, donc le mode Automated n'a jamais fonctionné tel quel | Corrigé (apostrophes typographiques), vérifié par `node --check` |
| `dev-plan/agents/*.md` (architect, challenger, developer) ne sont référencés nulle part dans `dev-plan/SKILL.md` | Le plan était produit sans ces agents, malgré ce qu'annonçait le README | Conservés dans `skills/dev-plan/prompts/` ; branchés au M2 (`planner-dev`, `planner-cto`, `plan-challenger`) |
| `dev-review/agents/*.md` non utilisés : `workflow.js` a ses propres prompts, plus courts | Les grilles détaillées (upload, OWASP) n'étaient pas appliquées | Conservés dans `skills/dev-review/prompts/` ; fusionnés au M2 |
| `skills/_shared/php-conventions.md` n'est lu par aucun skill | Les conventions PHP n'étaient pas injectées | `knowledge/stacks/php-native.md` est lu par `dev-implement` dès le M1 |
| `workflow('dev-review')` dans un workflow de plugin | Un nom non préfixé n'est pas résolu (`no workflow with that name`) | `workflow('devflow:dev-review-run')` |
| Workflows et skills homonymes (`dev-cycle`, `dev-review`) | Collision de commandes `/devflow:…` dans un plugin | Workflows renommés `dev-cycle-run`, `dev-review-run` |
