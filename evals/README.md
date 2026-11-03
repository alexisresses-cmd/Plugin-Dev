# Tickets de référence

> Principe D6 : on mesure avant d'élargir. Chaque profil, mode et type de tâche est couvert par au moins un ticket de référence, et aucun nouveau profil n'est ajouté sans ticket associé.

## Structure

```
evals/
├── tickets/<id>.md              # spécification lisible du ticket
├── _fixtures/<fixture>/         # projets témoins statiques + scaffold.sh
├── cases/<id>-<phase>/          # cases exécutables par `claude plugin eval` (ADR 0006)
└── results/
    ├── YYYYMMDD-vX.Y.md         # rapport de jalon (commité)
    └── <horodatage>/            # sorties brutes (ignorées par git)
```

## Lancer les évals

```bash
# Tous les cases (coût réel : appels modèle facturés)
claude plugin eval . --scaffold --trust-plugin --no-publish

# Un sous-ensemble, sans run de comparaison sans plugin
claude plugin eval . --case 'symfony-*' --scaffold --trust-plugin --no-publish --ablation none --allow-tools Write
```

`--scaffold` est nécessaire pour construire le projet témoin. `--allow-tools Write` est nécessaire aux cases qui produisent un fichier (`analysis/…`).

Une commande `/devflow:…` écrite dans le prompt est développée directement, sans passer par l'outil `Skill`. Pour vérifier qu'un skill a bien tourné, on contrôle donc un effet observable (ex. lecture de ses prompts avec `tool_used: Read`). Les cases qui accordent `Bash` exigent le sandbox OS (bubblewrap + socat sous Linux).

## Validation structurelle (sans appel modèle)

`scripts/validate.sh` vérifie JSON, YAML, frontmatters, sections des profils, modes et tâches, chaînes `extends` et références `devflow:<nom>` ; il tourne en CI (`.github/workflows/validate.yml`).
En local : `scripts/validate.sh` (PyYAML requis : `pip install pyyaml`) ; `--root <dir>` valide une autre copie.
`tests/validate/run.sh` prouve sur une copie cassée que chaque erreur est détectée.

## Cases disponibles

| Case | Phase | Bash (sandbox) |
|---|---|---|
| `hook-block-secrets`, `hook-protect-wordpress` | hook (comparaison avec / sans plugin) | non |
| `rules-symfony-reviewer-quality`, `rules-legacy-test-writer-refactor`, `rules-symfony-gate-checker-bugfix` | RESOLVER (3 combinaisons) | non |
| `rules-angular-reviewer-quality` | RESOLVER, profil angular (critères de review front ; fixture `angular-app`) | non |
| `init-symfony`, `init-php-legacy`, `init-wordpress`, `init-nest-greenfield`, `init-mixed` | `/devflow:init --yes` | non |
| `discover-php-legacy`, `discover-wordpress` | `/devflow:discover --yes` (scaffold `--no-conventions`) | non |
| `symfony-feature-01-analyse`, `symfony-bugfix-01-analyse`, `php-legacy-feature-01-analyse`, `symfony-fastlane-01-analyse`, `wp-legacy-feature-01-analyse`, `nest-greenfield-feature-01-analyse`, `angular-feature-01-analyse`, `mixed-feature-01-analyse` | dev-analyse | non |
| `symfony-feature-01-plan`, `php-legacy-refactor-01-plan`, `wp-legacy-refactor-01-plan`, `nest-greenfield-feature-01-plan`, `mixed-feature-01-plan` | dev-plan (jusqu'à la validation) | non |
| `symfony-feature-01-review` | dev-review | **oui** |
| `php-legacy-refactor-01-cycle` | dev-cycle avec G0 | **oui** |
| `symfony-fastlane-01-cycle` | dev-cycle, voie rapide | **oui** |

Les cases marqués **oui** portent le tag `needs-sandbox` et tournent dans la CI (`evals.yml`).

`hook-protect-wordpress` se lance sans `--ablation none` et avec `--allow-tools Edit Write` : le grader `regex` vérifie que `wp-content/themes/parent-theme/functions.php` contient toujours la faute (fichier inchangé) dans les deux bras ; attendu 1,00 avec le plugin et 0,00 sans. Un grader `tool_used` sur Edit ne suffirait pas : il compte l'appel, refusé ou non.

```bash
claude plugin eval . --case 'hook-protect-wordpress' --scaffold --trust-plugin --no-publish --allow-tools Edit Write
claude plugin eval . --case 'wp-*' --scaffold --trust-plugin --no-publish --ablation none --allow-tools Write Edit
claude plugin eval . --case 'init-wordpress' --scaffold --trust-plugin --no-publish --ablation none --allow-tools Write Edit
```

Jalon M5 (profils TypeScript et projets mixtes) :

```bash
claude plugin eval . --case 'init-nest-greenfield' --scaffold --trust-plugin --no-publish --ablation none --allow-tools Write Edit
claude plugin eval . --case 'init-mixed' --scaffold --trust-plugin --no-publish --ablation none --allow-tools Write Edit
claude plugin eval . --case 'nest-greenfield-*' --scaffold --trust-plugin --no-publish --ablation none --allow-tools Write
claude plugin eval . --case 'angular-*' --scaffold --trust-plugin --no-publish --ablation none --allow-tools Write
claude plugin eval . --case 'mixed-*' --scaffold --trust-plugin --no-publish --ablation none --allow-tools Write
```

`init-mixed` attend deux blocs `stacks[]` (`api/` → `symfony`, `front/` → `angular`, tous deux `modern`) ; `mixed-feature-01-plan` part d'une analyse de taille L et attend les deux planners, puis un plan qui met à jour le contrat (DTO PHP et interface TS) dans l'ordre contrat → serveur → client.

## Format d'un ticket

```markdown
---
id: wp-legacy-refactor-01
project: <chemin, URL ou fixture>
profile: wordpress
mode: legacy
task_type: refactor
size: M            # S | M | L
milestone: M4      # jalon à partir duquel le ticket doit passer
---
## Ticket
<texte du ticket, tel qu'un développeur le recevrait>

## Critères attendus
- [ ] critère vérifiable
```

## Projets témoins

Les projets sont **fictifs** : chaque ticket nomme dans `project` une fixture (`fixture:<nom>`) décrite dans sa section `## Projet témoin`. Les fixtures sont créées dans `_fixtures/` au jalon où leurs tickets deviennent exécutables (`symfony-api` : M1, `php-legacy-shop` : M3, `wp-legacy-theme` : M4, `nest-greenfield`, `angular-app`, `mixed-angular-symfony` : M5). `claude-v0/` contient le `CLAUDE.md` devflow v0 de chaque fixture utilisée par un case `init-*` (option `--no-devflow`) ; `analyses/` les analyses validées qui alimentent les cases de plan (option `--analysis`).

| Fixture | Profil(s) | Mode |
|---|---|---|
| `php-legacy-shop` | php-native | legacy |
| `symfony-api` | symfony | modern |
| `wp-legacy-theme` | wordpress | legacy |
| `nest-greenfield` | nestjs | greenfield |
| `angular-app` | angular | modern |
| `mixed-angular-symfony` | angular (`front/`) + symfony (`api/`) | modern |

## Couverture

| Ticket | Profil | Mode | Type | Taille | Jalon |
|---|---|---|---|---|---|
| `symfony-modern-feature-01` | symfony | modern | feature | M | M1 |
| `symfony-modern-bugfix-01` | symfony | modern | bugfix | M | M1 |
| `php-legacy-feature-01` | php-native | legacy | feature | M | M3 |
| `php-legacy-refactor-01` | php-native | legacy | refactor | M | M3 |
| `symfony-modern-fastlane-01` | symfony | modern | bugfix | **S** | M3 |
| `wp-legacy-feature-01` | wordpress | legacy | feature | M | M4 |
| `wp-legacy-refactor-01` | wordpress | legacy | refactor | M | M4 |
| `nest-greenfield-feature-01` | nestjs | greenfield | feature | M | M5 |
| `angular-modern-feature-01` | angular | modern | feature | M | M5 |
| `mixed-modern-feature-01` | angular + symfony | modern | feature | L | M5 |

## Rapport d'exécution

`results/YYYYMMDD-vX.Y.md`, avec pour chaque ticket : critères OK / KO, tokens consommés, gates passées au premier essai, findings jugés invalides par `review-challenger`, retouches manuelles.

## Critères communs à tous les tickets

Sauf mention contraire, chaque ticket vérifie aussi :
- [ ] Fichier `analysis/YYYYMMDD-{slug}.md` créé avec `task_type`, `size`, `profiles` corrects.
- [ ] Tous les commits passent par `dev-commit` et respectent `git.commit_format`.
- [ ] Aucun fichier modifié hors du périmètre du plan.
- [ ] Aucun secret lu ni écrit (`.env*`, `*.pem`, `*.key`…).
