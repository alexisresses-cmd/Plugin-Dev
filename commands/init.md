---
description: Qualifie le projet pour devflow (profils de stack, mode de maturité, outillage, conventions git) et génère .devflow/config.yml après validation
argument-hint: "[--yes] [--greenfield]"
---

# /devflow:init — Qualification du projet

Arguments : `$ARGUMENTS`
- `--yes` : n'affiche aucune question ; applique les valeurs proposées (et les valeurs par défaut du modèle pour ce qui ne se détecte pas). Ne remplace jamais un `.devflow/config.yml` existant.
- `--greenfield` : projet neuf (voir étape 6).

Tu proposes, l'utilisateur valide. Toute détection est **justifiée par des signaux observés** (fichier, valeur, commande).

## Étape 0 — Existant

- `.devflow/config.yml` existe déjà : affiche-le et demande s'il faut le mettre à jour (avec `--yes` : arrête-toi et le signaler).
- Lis le `CLAUDE.md` du projet. S'il contient les clés de devflow v0 (`BRANCH_PREFIX`, `COMMIT_FORMAT`, `ISSUE_TRACKER`, `MAIN_REVIEWER`), reprends leurs valeurs comme propositions.

## Étape 1 — Profils de stack

1. Liste les profils disponibles : en-têtes YAML de `${CLAUDE_PLUGIN_ROOT}/knowledge/stacks/*.md` (hors `_template.md`). Lis uniquement l'en-tête (`profile`, `extends`, `detect`).
2. Repère les sous-projets : la racine, et chaque dossier jusqu'à 2 niveaux qui contient un `composer.json`, un `package.json`, un `tsconfig.json`, un `angular.json`, un `nest-cli.json`, un `wp-config.php`, un `wp-load.php` ou un `style.css` (ignore `vendor/`, `node_modules/`, `.git/`, `dist/`, `build/`). Le cas WordPress est traité à l'étape 1 bis.
3. Pour chaque sous-projet, évalue les conditions `detect` de chaque profil : `files_any` (présence ; n'ouvre jamais `wp-config.php`, sa présence suffit), `composer_require_any` (clés `require` et `require-dev` de `composer.json`), `package_json_any` (`dependencies` et `devDependencies`), `headers_any` (le texte `header` dans les 30 premières lignes d'un fichier `file` à la racine du sous-projet, par exemple `Theme Name:` dans `style.css` ou `Plugin Name:` dans un `*.php`). Retiens le profil **le plus spécifique** qui correspond (le plus profond dans la chaîne `extends`) : `@nestjs/core` → `nestjs` (même si `express` est présent) ; `express` / `fastify` sans Nest → `node` ; `@angular/core` → `angular` ; `typescript` ou `tsconfig.json` seul → `typescript`. PHP sans `composer.json` → `php-native`.
4. Profil détecté mais absent de cette version du plugin : signale-le et propose le parent disponible le plus proche, ou de l'ignorer.
5. **Projet mixte** (plusieurs sous-projets détectés) : un bloc `stacks[]` par sous-projet, avec son `path` (relatif à la racine, `/` final), son profil et son mode (étape 3). Le dossier racine ne produit un bloc que s'il contient lui-même du code applicatif : un `package.json` racine de workspaces ou d'outillage seul n'en produit pas. Place un éventuel bloc `./` en premier (bloc par défaut des fichiers hors de tout `path`).

   ```yaml
   stacks:
     - path: api/
       profile: symfony
       mode: modern
     - path: front/
       profile: angular
       mode: modern
   ```

## Étape 1 bis — WordPress

Si le profil `wordpress` est détecté :

1. **Type** (`wordpress.type`), par sous-projet :
   | Signal | Type |
   |---|---|
   | `style.css` avec `Theme Name:` **et** `Template: <parent>` | `child-theme` |
   | `style.css` avec `Theme Name:` sans `Template:` | `theme` |
   | `*.php` avec `Plugin Name:`, dossier sous `wp-content/mu-plugins/` | `mu-plugin` |
   | `*.php` avec `Plugin Name:` ailleurs | `plugin` |
   | `wp-load.php`, `wp-config.php` ou `wp-includes/version.php` à la racine | `site` |
2. **Site complet à la racine** : cherche le code propre à l'équipe dans `wp-content/themes/*/style.css`, `wp-content/plugins/*/*.php` et `wp-content/mu-plugins/`. Sont proposés comme blocs `stacks[]` (un par dossier, `path` = le dossier) : les thèmes enfants, les mu-plugins, et tout thème ou extension que l'utilisateur désigne comme maison. Les autres thèmes et extensions sont considérés comme tiers (avec `--yes` : tiers). Aucun code maison trouvé → un seul bloc `path: ./`, type `site`.
3. **Chemins protégés** (`wordpress.protected`), relatifs à la racine du projet, avec `/` final :
   - `wp-admin/` et `wp-includes/` ;
   - `wp-content/plugins/` : l'extension du bloc reste modifiable (le hook `protect-paths.sh` exempte le `path` de chaque bloc, même placé sous un chemin protégé) ;
   - pour un thème enfant, le dossier du thème parent (`wp-content/themes/<valeur de Template:>/`) ;
   - n'inscris que les chemins présents dans le dépôt ; dépôt limité au thème ou à l'extension → `protected: []`.
4. Blocs Gutenberg : un dossier de bloc ou d'extension avec un `package.json` (`@wordpress/scripts`) reçoit son propre bloc `stacks[]` de profil `typescript` dont le `path` est le dossier des sources JavaScript (ex. `wp-content/plugins/mt-blocks/src/`) ; le PHP reste ainsi dans le bloc `wordpress`.

Bloc généré (thème enfant d'un site complet) :

```yaml
  - path: wp-content/themes/mon-theme/
    profile: wordpress
    mode: legacy
    wordpress:
      type: child-theme
      protected:
        - wp-admin/
        - wp-includes/
        - wp-content/plugins/
        - wp-content/themes/parent-theme/
```

## Étape 2 — Outillage

Pour chaque sous-projet, détecte (sinon `null`). Pour TypeScript, préfère les scripts de `package.json` (`test`, `lint`, `test:e2e`) aux commandes brutes.

| Clé | Signaux |
|---|---|
| `tooling.test` | `vendor/bin/phpunit` ou `bin/phpunit` + `phpunit.xml*` (WordPress : `brain/monkey`, `.wp-env.json`) |
| `tooling.lint` | `phpcs.xml*` / `vendor/bin/phpcs` (WordPress : `wp-coding-standards/wpcs` → `vendor/bin/phpcs --standard=WordPress`) ; `.php-cs-fixer*.php` → `vendor/bin/php-cs-fixer fix --dry-run --diff` |
| `tooling.static_analysis` | `phpstan.neon*` → `vendor/bin/phpstan analyse --no-progress` ; `psalm.xml*` → `vendor/bin/psalm` |
| `tooling.static_analysis_baseline` | `phpstan-baseline.neon`, `psalm-baseline.xml` |
| `tooling.test` (TypeScript) | `vitest` → `npx vitest run` ; `jest` → `npx jest` ; Angular : `npx ng test` si `test` est configuré dans `angular.json` ; NestJS : `npm test && npm run test:e2e` |
| `tooling.lint` (TypeScript) | `eslint.config.*` / `.eslintrc*` → `npx eslint .` ; Angular : `npx ng lint` si `lint` est configuré dans `angular.json` |
| `tooling.static_analysis` (TypeScript) | `tsconfig.json` → `npx tsc --noEmit` (Angular : `-p tsconfig.app.json`) |

`tooling` reste **global** (une commande par clé, lancée depuis la racine du dépôt) : `gate-checker` et `test-writer` n'ont qu'une commande à exécuter. En projet mixte, chaque clé enchaîne les commandes des sous-projets, chacune dans un sous-shell qui se place dans son dossier, dans l'ordre des blocs : `"(cd api && vendor/bin/phpunit) && (cd front && npx vitest run)"`. Un sous-projet sans outil pour une clé est omis de la chaîne ; aucun outil → `null`. `static_analysis_baseline` reste un chemin relatif à la racine (`api/phpstan-baseline.neon`).

Signale aussi la CI (`.github/workflows/`, `.gitlab-ci.yml`), pour information.

## Étape 3 — Mode de maturité (par profil)

Mesure et affiche ces signaux, puis propose un mode :

| Signal | Commande indicative |
|---|---|
| Version PHP | `require.php` de `composer.json`, sinon `php -v` |
| Version TypeScript / framework | `typescript`, `@angular/core`, `@nestjs/core` dans `package.json` ; `engines.node` |
| Typage strict (TypeScript) | `"strict": true` dans `tsconfig.json` |
| Tests | nombre de fichiers de tests ; présence de `tooling.test` |
| Namespaces | part des fichiers PHP avec `namespace` |
| Taille | lignes moyennes des fichiers PHP ou TypeScript du code applicatif (hors `vendor/`, `node_modules/`, `dist/`) |
| Âge et activité | date du premier commit, nombre de commits |

Les signaux portent sur le code du sous-projet seulement : pour WordPress, le `path` du bloc, sans les chemins protégés ni le code tiers.

- **legacy** : au moins deux signaux parmi : PHP < 7.4, pas de Composer, pas de tests, moins de 50 % de fichiers avec namespace, plus de 400 lignes en moyenne. TypeScript : pas de tests, `strict` absent, Angular < 15 (NgModules partout), Node < 18, plus de 400 lignes en moyenne.
- **greenfield** : option `--greenfield`, ou code applicatif quasi vide (moins de 5 fichiers source hors configuration et tests ; TypeScript : `*.ts` hors `*.spec.ts`, `*.d.ts` et fichiers de configuration, ce qui couvre un projet tout juste créé par `nest new` ou `ng new`). En projet mixte, la règle s'applique à chaque sous-projet séparément. Le nombre de commits n'est **pas** un signal suffisant (clone partiel, import récent).
- **modern** : sinon.

## Étape 4 — Git et tracker

Propose, en justifiant :
- `git.base_branch` : `git symbolic-ref refs/remotes/origin/HEAD`, sinon `main` ;
- `git.branch_prefix` : préfixe dominant des branches existantes (`git branch -a`), sinon `feat/` ;
- `git.commit_format` : `conventional` si la majorité des 30 derniers sujets de commit respectent `type(scope): …`, sinon décris le format observé ;
- `git.ticket_ref_format` : forme observée dans les commits (`#42`, `PROJ-42`), sinon `#{id}` ;
- `git.main_reviewer` : à demander (sans `--yes`), sinon `null` ;
- `issue_tracker` : `github` si le remote est sur github.com, sinon `text`.

## Étape 5 — Validation et génération

Sans `--yes` : présente la proposition complète (profils et modes avec leurs signaux, outillage, git, tracker), puis utilise **AskUserQuestion** pour faire valider ou corriger le mode de chaque profil et les valeurs git non détectées. Applique les corrections.

Ensuite :
1. Écris `.devflow/config.yml` à partir de `${CLAUDE_PLUGIN_ROOT}/templates/config.yml` (garde les commentaires du modèle).
2. Crée `.devflow/conventions.md` à partir de `${CLAUDE_PLUGIN_ROOT}/templates/conventions.md` s'il n'existe pas. Si `CLAUDE.md` contient des conventions de projet (section « Conventions spécifiques » de la v0), recopie-les dans les sections correspondantes.
3. Ajoute `.devflow/config.local.yml` au `.gitignore` (crée le fichier si besoin ; pas de doublon).
4. `CLAUDE.md` : s'il n'a pas de section `## devflow`, ajoute en fin de fichier le contenu de `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.snippet.md`. Ne modifie et ne supprime rien d'autre (signale seulement les anciennes clés v0, désormais inutiles).

## Étape 6 — Option `--greenfield`

- Liste l'outillage manquant pour le profil (tests, lint, analyse statique, CI) et propose les commandes d'installation (ex. `composer require --dev phpunit/phpunit phpstan/phpstan`). **Ne les lance pas sans accord explicite** (avec `--yes` : ne les lance pas).
- Rédige le premier ADR, `docs/adr/0001-choix-de-la-stack.md`, à partir de `${CLAUDE_PLUGIN_ROOT}/templates/adr.md` : stack, structure des dossiers, outillage retenu.

## Bilan

```
✅ devflow initialisé
  {path} → {profil} ({mode}) — signaux : …
  WordPress : type={…} protégés={…}
  Outillage : test={…} lint={…} analyse={…}
  Git : base={…} préfixe={…} commits={…}
  Fichiers : .devflow/config.yml, .devflow/conventions.md, .gitignore, CLAUDE.md

Suite : /devflow:dev-analyse <ticket>
```

Si un profil est en mode `legacy`, remplace la ligne « Suite » par : « Suite : /devflow:discover (carte du projet et conventions observées), puis /devflow:dev-analyse <ticket> ».
