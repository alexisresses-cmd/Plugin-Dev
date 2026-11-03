# DEVFLOW — Spécification (figée)

> Copie figée des sections 1 à 4 du plan de développement initial (DEVFLOW-PLAN.md).
> Toute évolution passe par un ADR dans `docs/adr/`, pas par une modification de ce fichier.
> Les écarts constatés lors des spikes M0 sont dans [`adr/0001-plugin-mechanics.md`](adr/0001-plugin-mechanics.md).

---

## 1. Principes d'architecture (décisions figées)

### D1 — Trois axes indépendants

| Axe | Valeurs v1 | Porté par | Fixé où |
|---|---|---|---|
| **Stack** | `php-native`, `symfony`, `wordpress`, `typescript`, `node`, `nestjs`, `angular` | le projet (par dossier) | `.devflow/config.yml` |
| **Mode de maturité** | `legacy`, `modern`, `greenfield` | le projet (par dossier) | `.devflow/config.yml` |
| **Type de tâche** | `feature`, `bugfix`, `refactor` | le ticket | fichier d'analyse du ticket |

Les agents sont **les mêmes** pour toutes les combinaisons ; ce sont **les règles qu'ils chargent** qui changent.

### D2 — Ordre de priorité des règles (du plus fort au plus faible)

```
1. .devflow/conventions.md         (conventions observées et validées dans le projet)
2. knowledge/tasks/<type>.md       (règles du type de tâche)
3. knowledge/modes/<mode>.md       (règles du mode de maturité)
4. knowledge/stacks/<stack>.md     (profil de stack, avec héritage)
5. knowledge/core/clean-code.md    (principes génériques)
```

Règle clé pour le legacy : **les conventions observées priment sur les conventions idéales.**

### D3 — Héritage des profils de stack

```
php-native
 ├── symfony      extends: php-native
 └── wordpress    extends: php-native   (WPCS remplace PSR-12)

typescript
 ├── node         extends: typescript   (Express / Fastify)
 │    └── nestjs  extends: node
 └── angular      extends: typescript
```

Un profil enfant ne décrit que ses différences. Laravel est **hors périmètre**.

### D4 — Le skill orchestre, l'agent exécute

- **Skill** : chargé dans la conversation, peut dialoguer avec l'utilisateur, demander une validation, agir sur git / GitHub.
- **Agent** : contexte isolé, outils et modèle restreints, travaille seul et renvoie un résultat structuré.
- **Contrainte :** un agent ne peut pas lancer d'autres agents. La parallélisation part toujours d'un skill.
- **Contrainte :** un agent ne peut pas demander de validation. Toute validation reste dans le skill.

### D5 — Configuration du projet dans `.devflow/`

Le `CLAUDE.md` du projet ne contient que des imports ; la configuration est dans `.devflow/`. Trois niveaux :

```
réglages par défaut du plugin  <  .devflow/config.yml (commité, équipe)  <  .devflow/config.local.yml (gitignoré, perso)
```

Les réglages personnels d'Alexis (`dev-simplifier`, hook anti-commentaires) vont dans `config.local.yml` et ne sont pas imposés à l'équipe.

### D6 — Mesurer avant d'élargir

Chaque profil, mode et type de tâche est validé par des **tickets de référence** (`evals/`). Pas de nouveau profil sans ticket de référence associé.

---

## 2. Structure cible du repo

```
ai-claude-dev-workflow/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── skills/
│   ├── dev-analyse/SKILL.md        # orchestrateur
│   ├── dev-plan/SKILL.md           # orchestrateur
│   ├── dev-cycle/SKILL.md          # chef d'orchestre
│   ├── dev-implement/SKILL.md
│   ├── dev-test/SKILL.md           # orchestrateur léger → test-writer
│   ├── dev-review/SKILL.md         # orchestrateur
│   ├── challenge-review/SKILL.md   # wrapper → review-challenger
│   ├── dev-pr/SKILL.md
│   ├── dev-commit/SKILL.md
│   ├── review-return/SKILL.md
│   └── dev-copilot/SKILL.md
├── commands/
│   ├── init.md                     # /devflow:init
│   ├── discover.md                 # /devflow:discover
│   └── dev-branch.md
├── agents/
│   ├── business-analyst.md
│   ├── code-mapper.md
│   ├── architect.md
│   ├── security-analyst.md
│   ├── planner-dev.md
│   ├── planner-cto.md
│   ├── plan-challenger.md
│   ├── test-writer.md
│   ├── reviewer-quality.md
│   ├── reviewer-bugs.md
│   ├── reviewer-security.md
│   ├── review-challenger.md
│   ├── gate-checker.md
│   ├── dev-simplifier.md
│   ├── cartographer.md
│   ├── convention-detector.md
│   └── risk-mapper.md
├── knowledge/
│   ├── RESOLVER.md                 # procédure de chargement des règles, lue par tous les agents
│   ├── core/clean-code.md
│   ├── stacks/
│   │   ├── _template.md
│   │   ├── php-native.md
│   │   ├── symfony.md
│   │   ├── wordpress.md
│   │   ├── typescript.md
│   │   ├── node.md
│   │   ├── nestjs.md
│   │   └── angular.md
│   ├── modes/
│   │   ├── legacy.md
│   │   ├── modern.md
│   │   └── greenfield.md
│   └── tasks/
│       ├── feature.md
│       ├── bugfix.md
│       └── refactor.md
├── hooks/
│   ├── hooks.json
│   └── scripts/
│       ├── read-config.sh          # lit .devflow/config(.local).yml
│       ├── block-secrets.sh
│       ├── block-dangerous.sh      # remplace les règles deny de settings.json
│       └── no-comments.sh
├── templates/
│   ├── config.yml
│   ├── conventions.md
│   ├── project-map.md
│   ├── adr.md
│   └── CLAUDE.snippet.md
├── evals/
│   ├── README.md
│   ├── tickets/                    # tickets de référence
│   └── results/                    # rapports d'exécution
├── docs/
│   ├── SPEC.md                     # copie figée de la section 1-4 de ce fichier
│   ├── adr/
│   ├── adding-a-stack.md
│   └── migration-from-v0.md
├── .github/workflows/validate.yml
├── CHANGELOG.md
├── LICENSE
└── README.md
```

---

## 3. Spécifications détaillées

### 3.1 `.devflow/config.yml` (dans le projet utilisateur)

```yaml
schema_version: 1

stacks:
  - path: api/
    profile: symfony
    mode: modern
  - path: front/
    profile: angular
    mode: legacy
  - path: wp-content/themes/mon-theme/
    profile: wordpress
    mode: legacy
    wordpress:
      type: child-theme          # theme | child-theme | plugin | mu-plugin | site
      protected:                 # jamais modifiés
        - wp-admin/
        - wp-includes/
        - wp-content/plugins/

tooling:                         # détecté par /devflow:init, modifiable
  test: "vendor/bin/phpunit"     # ou null
  lint: "vendor/bin/phpcs"
  static_analysis: "vendor/bin/phpstan analyse"
  static_analysis_baseline: phpstan-baseline.neon

git:
  branch_prefix: feat/
  commit_format: conventional
  ticket_ref_format: "#{id}"
  main_reviewer: "@handle"

issue_tracker: github            # github | zenhub | trello | jira | linear | text

pipeline:
  fast_lane: true                # voie rapide pour les tickets de taille S
  checkpoints: true              # validations humaines entre phases dans dev-cycle

hooks:
  no_comments: false
  block_secrets: true
```

`config.local.yml` : même schéma, toutes les clés facultatives, fusion profonde par-dessus `config.yml`. Ajouté au `.gitignore` par `/devflow:init`.

Si un fichier ne correspond à aucun `path`, le profil est celui du `path` parent le plus proche, sinon le premier de la liste.

### 3.2 `knowledge/RESOLVER.md` (procédure commune à tous les agents)

Chaque agent commence par cette procédure (référencée dans son prompt via `${CLAUDE_PLUGIN_ROOT}/knowledge/RESOLVER.md`) :

1. Lire `.devflow/config.yml` puis fusionner `.devflow/config.local.yml`. Absent → s'arrêter et demander de lancer `/devflow:init` (ou, pour un agent, renvoyer une erreur structurée à l'orchestrateur).
2. Lire le type de tâche dans le fichier d'analyse du ticket (`analysis/*.md`, champ `task_type`).
3. Déterminer les profils concernés à partir des fichiers du diff / du périmètre (un ticket peut toucher plusieurs profils).
4. Pour chaque profil, résoudre la chaîne d'héritage (`extends`) et charger **uniquement la section dont l'agent a besoin** (voir 3.3).
5. Charger dans `modes/<mode>.md` et `tasks/<type>.md` **uniquement la section de l'agent**.
6. Charger `.devflow/conventions.md` et `.devflow/project-map.md` s'ils existent.
7. Appliquer l'ordre de priorité D2 en cas de conflit.

Objectif : économie de tokens. Un agent ne lit jamais un profil complet.

### 3.3 Contrat des fichiers de profil (`knowledge/stacks/_template.md`)

En-tête obligatoire :

```yaml
---
profile: symfony
extends: php-native        # ou null
detect:                    # utilisé par /devflow:init
  files_any: [symfony.lock]
  composer_require_any: [symfony/framework-bundle]
---
```

Sections obligatoires (titres exacts, vérifiés par la CI) :

| Section | Utilisée par |
|---|---|
| `## Conventions` | `dev-implement`, `reviewer-quality`, `convention-detector` |
| `## Architecture` | `architect`, `code-mapper`, `planner-*` |
| `## Testing` | `test-writer`, `gate-checker` |
| `## Security` | `security-analyst`, `reviewer-security` |
| `## Data & migrations` | `planner-*`, `reviewer-bugs` |
| `## Simplification` | `dev-simplifier` |
| `## Tooling` | `gate-checker`, `/devflow:init` |

Un profil enfant peut écrire `_inherit_` dans une section pour reprendre celle du parent sans ajout.

### 3.4 Contrat des fichiers de mode et de type de tâche

`modes/<mode>.md` et `tasks/<type>.md` ont une section par phase/agent :
`## analyse`, `## plan`, `## implement`, `## test`, `## review`, `## simplifier`, `## gates`, `## pr`.

**Contenu attendu — modes :**

| Phase | `legacy` | `modern` | `greenfield` |
|---|---|---|---|
| analyse | part de `project-map.md` ; repère code mort, couplages cachés, effets de bord | standard | choix d'architecture, pas d'analyse de l'existant |
| plan | changement minimal, pas de refactoring hors périmètre | standard | structure, outillage, ADR |
| implement | imite les conventions observées ; nettoyage limité au code touché | conventions de la stack | stack idéale à la lettre |
| test | tests de caractérisation d'abord, sinon plan de test manuel renforcé | tests unitaires du framework détecté | tests dès le départ, objectif de couverture |
| review | juge le diff seul ; dette existante signalée sans bloquer ; focus régressions | complète | complète et stricte |
| simplifier | prudent : réduit le diff, jamais l'existant | normal | agressif |
| gates | règle du cliquet : ne pas aggraver (baseline) | seuils standards | seuils stricts |

**Contenu attendu — types de tâche :**

| Phase | `feature` | `bugfix` | `refactor` |
|---|---|---|---|
| analyse | besoin métier, impacts | cause du bug, périmètre | dette visée, dépendances, risques |
| plan | découpage en tâches | correctif minimal | petites étapes réversibles (Mikado) ; strangler fig / branch by abstraction si gros chantier |
| test | tests du nouveau comportement | test qui reproduit le bug **avant** le correctif | tests de caractérisation **avant** toute modification (gate G0) |
| implement | normale | correction ciblée | une transformation par commit, tests verts à chaque commit |
| review | qualité, bugs, sécurité | bug corrigé, rien d'autre cassé | **équivalence de comportement**, aucun changement fonctionnel |
| simplifier | réduit le diff | réduit le diff | plus libre dans le périmètre |
| pr | apport de la fonctionnalité | cause + correctif | avant / après + preuve d'équivalence ; proposer une requalification du mode si outillage ajouté |

Règle refactor : un bug découvert pendant un refactoring est **signalé** (proposition de ticket séparé), jamais corrigé dans la même PR.

### 3.5 Agents

Les prompts des sous-agents existants (aujourd'hui écrits dans les skills) sont **extraits** vers `agents/`. Chaque agent : frontmatter (`name`, `description`, `tools`, `model`), puis « Lis et applique `${CLAUDE_PLUGIN_ROOT}/knowledge/RESOLVER.md` pour la section `<X>` », puis la mission, puis le **format de sortie structuré** (JSON ou markdown à sections fixes).

| Agent | Origine | Outils | Modèle | Sortie |
|---|---|---|---|---|
| `business-analyst` | dev-analyse | lecture | sonnet | besoins, critères d'acceptation, questions ouvertes |
| `code-mapper` | dev-analyse | lecture | haiku | fichiers concernés, points d'entrée |
| `architect` | dev-analyse | lecture | opus | impacts, options, recommandation |
| `security-analyst` | dev-analyse | lecture | sonnet | risques (conditionnel, selon triage) |
| `planner-dev` | dev-plan | lecture | sonnet | tâches ordonnées |
| `planner-cto` | dev-plan | lecture | sonnet | arbitrages, risques, mode recommandé |
| `plan-challenger` | dev-plan | lecture | opus | objections au plan |
| `test-writer` | dev-test | lecture + écriture | sonnet | fichiers de test + plan de test manuel |
| `reviewer-quality` | dev-review | lecture + `git diff` | sonnet | findings JSON |
| `reviewer-bugs` | dev-review | lecture + `git diff` | opus | findings JSON (+ équivalence en refactor) |
| `reviewer-security` | dev-review | lecture + `git diff` | opus | findings JSON (conditionnel) |
| `review-challenger` | challenge-review | lecture | opus | verdict par finding : valide / discutable / invalide |
| `gate-checker` | gates G0/G1/G2 | lecture + commandes `tooling` | haiku | `{gate, status: PASS/FAIL, reasons[]}` |
| `dev-simplifier` | existant | lecture + écriture | sonnet | diff réduit |
| `cartographer` | nouveau (discover) | lecture | sonnet | modules, points d'entrée, flux |
| `convention-detector` | nouveau (discover) | lecture | sonnet | brouillon de `conventions.md` |
| `risk-mapper` | nouveau (discover) | lecture | sonnet | zones fragiles, duplication, dépendances obsolètes |

Format commun des findings de review :

```json
[{ "id": "R1", "severity": "blocking|should-fix|note", "file": "", "line": 0,
   "issue": "", "fix": "", "rule_source": "stack|mode|task|conventions|core" }]
```

### 3.6 Skills (orchestrateurs)

- **`dev-analyse`** : triage (taille S/M/L, type de tâche, besoin d'un audit sécurité) → lance en parallèle les agents d'analyse utiles → synthèse → écrit `analysis/YYYYMMDD-{slug}.md` avec `task_type`, `size`, `profiles`.
- **`dev-plan`** : lance les planners en parallèle → synthèse → **validation utilisateur** → branche + draft PR via `dev-commit` / gh → recommande le mode d'exécution.
- **`dev-cycle`** : enchaîne implement → `gate-checker` (G0 si refactor, G1) → `test-writer` → reviewers en parallèle → `review-challenger` → `gate-checker` (G2) → auto-correction (2 tentatives max) → `dev-pr`. Avec `pipeline.checkpoints: true`, demande une validation entre phases. Remplace les modes Automated et Orchestra (Orchestra = dev-cycle avec checkpoints, chaque phase en agent isolé).
- **Voie rapide** (taille S, `fast_lane: true`) : implement → G1 → dev-commit → dev-pr.
- **`dev-implement`** : reste un skill (commits intermédiaires via `dev-commit`, l'utilisateur peut corriger en cours de route).
- **`dev-commit`** : seul endroit où le format de commit est appliqué ; lit `git.*` dans la config.
- **`dev-pr`, `review-return`, `dev-copilot`** : migrés, lisent `git.main_reviewer` et `issue_tracker` dans la config.

### 3.7 Commandes

**`/devflow:init`**
1. Détecte les profils (champ `detect` de chaque profil), y compris les projets mixtes (un `path` par sous-projet).
   - `wp-config.php` ou `style.css` avec en-tête de thème → `wordpress`
   - `symfony.lock` / `symfony/framework-bundle` → `symfony`
   - `composer.json` sans framework, ou PHP sans composer → `php-native`
   - `@nestjs/core` → `nestjs` ; `express` / `fastify` sans Nest → `node` ; `@angular/core` → `angular` ; `tsconfig.json` seul → `typescript`
2. Détecte l'outillage (tests, lint, analyse statique, baseline, CI).
3. Propose un mode par profil à partir de signaux : version PHP/Node, présence de tests, namespaces, taille moyenne des fichiers, âge du dépôt. **L'utilisateur valide ou corrige.**
4. Pose les questions git / tracker manquantes.
5. Génère `.devflow/config.yml`, ajoute `config.local.yml` au `.gitignore`, ajoute les imports dans `CLAUDE.md` (section `## devflow`, sans écraser l'existant).
6. Option `--greenfield` : propose d'installer l'outillage manquant et rédige le premier ADR.

**`/devflow:discover`** (projets legacy)
1. Lance `cartographer`, `convention-detector`, `risk-mapper` en parallèle.
2. Produit `.devflow/project-map.md` et un brouillon de `.devflow/conventions.md`.
3. Présente le brouillon à l'utilisateur, qui valide / corrige avant écriture.

### 3.8 Hooks

| Hook | Événement | Rôle |
|---|---|---|
| `block-secrets.sh` | PreToolUse (Read, Edit, Write, Bash) | Bloque lecture / écriture / commit de `.env*`, `wp-config.php`, `parameters.yml`, `*.pem`, `*.key` (désactivable via `hooks.block_secrets`) |
| `block-dangerous.sh` | PreToolUse (Bash) | Reprend les règles `deny` de l'ancien `settings.json` (ex. `rm -rf`, `git push --force` sur la branche principale, commandes visant une base de prod) |
| `no-comments.sh` | PostToolUse (Edit, Write) | Hook anti-commentaires existant, actif seulement si `hooks.no_comments: true` |
| protection WordPress | PreToolUse (Edit, Write) | Refuse toute modification dans `wordpress.protected` |

Tous les scripts utilisent `${CLAUDE_PLUGIN_ROOT}` et `read-config.sh`.

### 3.9 Profils v1 — points obligatoires

- **php-native** : PSR-12/PSR-4, typage, gestion d'erreurs, requêtes préparées (PDO), échappement des sorties, upload, sessions ; PHPUnit ; PHPStan ; legacy typique : includes, SQL dans le HTML, globals.
- **symfony** : services / DI, contrôleurs fins, Doctrine (migrations, requêtes DQL / QueryBuilder), Voters, Forms, Messenger ; PHPUnit + WebTestCase ; sécurité : CSRF, access_control, Voters.
- **wordpress** : WPCS, préfixes ou namespaces, hooks (`add_action` / `add_filter`), jamais de modification du cœur ni des extensions tierces, thème enfant ; types : thème, thème enfant, extension, mu-plugin, blocs Gutenberg (→ profil `typescript`) ; ACF, CPT, taxonomies ; sécurité : `sanitize_*`, `esc_*`, `wp_kses`, nonces, `current_user_can`, `$wpdb->prepare`, `permission_callback` REST, uploads ; tests : `WP_UnitTestCase` + `wp-env`, Brain Monkey ; outillage : WP-CLI, PHPCS + WPCS.
- **typescript** : `strict`, pas de `any` non justifié, ESLint, `tsc --noEmit`, Jest / Vitest.
- **node** : async/await, gestion d'erreurs, config par env, validation (zod), injection SQL/NoSQL, CORS, rate limiting, en-têtes HTTP, secrets ; Supertest.
- **nestjs** : modules, providers, DTO, `ValidationPipe` + class-validator, guards, `@Roles`, intercepteurs ; TypeORM / Prisma + migrations ; `Test.createTestingModule`, e2e.
- **angular** : standalone components, signals, OnPush, RxJS (désabonnements, `takeUntilDestroyed`), lazy loading ; sécurité : `bypassSecurityTrust*`, `innerHTML`, tokens côté client, guards ≠ contrôle serveur ; tests : Jest / Vitest, Cypress / Playwright ; review : accessibilité, taille du bundle. AngularJS 1.x hors périmètre.
- **Projets mixtes** : règle de review — si un contrat d'API change (DTO, route, schéma), les deux côtés sont mis à jour dans le même ticket.

### 3.10 Tickets de référence (`evals/`)

Format d'un ticket (`evals/tickets/<id>.md`) :

```markdown
---
id: wp-legacy-refactor-01
project: <chemin ou URL du projet témoin>
profile: wordpress
mode: legacy
task_type: refactor
size: M
---
## Ticket
<texte du ticket>

## Critères attendus
- [ ] Tests de caractérisation écrits avant toute modification (G0)
- [ ] Aucun fichier modifié dans wp-content/plugins/
- [ ] Aucun changement fonctionnel détecté par reviewer-bugs
- [ ] Commits au format de la config
```

Rapport (`evals/results/YYYYMMDD-vX.Y.md`) : par ticket, critères OK/KO, tokens consommés, gates passées au premier essai, findings jugés invalides par `review-challenger`, retouches manuelles.

Projets témoins : 1 PHP natif legacy, 1 Symfony, 1 WordPress legacy, 1 NestJS, 1 Angular, 1 mixte (Angular + NestJS ou Symfony + Angular). Alexis fournit les chemins en M0.

---

## 4. Points techniques à vérifier (spikes M0)

Ne pas supposer, vérifier dans la doc officielle des plugins Claude Code et par un test minimal :

1. Format exact de `plugin.json` et `marketplace.json` ; commande de validation éventuelle (`claude plugin validate`).
2. `${CLAUDE_PLUGIN_ROOT}` disponible dans les skills, les agents, les commandes et les hooks ?
3. Champs acceptés dans le frontmatter d'un agent (`tools`, `model`) et syntaxe de restriction des commandes Bash (ex. `Bash(git diff:*)`).
4. Un plugin peut-il définir des règles de permission (`deny`) ? Sinon → hooks (prévu en 3.8).
5. Format de `hooks/hooks.json` et variables d'entrée disponibles pour les scripts (chemin du fichier, commande).
6. Affichage et invocation des skills/commandes préfixés (`/devflow:...`).
7. Un agent peut-il lire un fichier hors du projet via `${CLAUDE_PLUGIN_ROOT}` ?

Consigner les résultats dans `docs/adr/0001-plugin-mechanics.md`. Si un point invalide une décision de ce plan, s'arrêter et proposer une alternative à Alexis.
