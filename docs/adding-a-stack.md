# Ajouter une stack

> Un profil de stack est un fichier `knowledge/stacks/<profil>.md` lu section par section par les agents (voir [RESOLVER](../knowledge/RESOLVER.md)). Contrat : SPEC § 3.3 et [ADR 0003](adr/0003-profile-inheritance.md).
> Règle D6 : pas de nouveau profil sans ticket de référence et cases d'éval associés.

Exemple suivi dans ce guide : un profil `laravel` qui étend `php-native`. Laravel n'est pas fourni en v1 (hors périmètre de la SPEC) : c'est une illustration.

## 1. Copier le modèle

```bash
cp knowledge/stacks/_template.md knowledge/stacks/laravel.md
```

Le nom du fichier est le nom du profil (kebab-case). Choisissez le parent le plus proche : un profil enfant ne décrit que ses **différences**.

## 2. En-tête `profile` / `extends` / `detect`

```yaml
---
profile: laravel
extends: php-native
detect:
  files_any: [artisan]
  composer_require_any: [laravel/framework]
  package_json_any: []
---
```

- `extends` : nom du parent, ou `null` pour un socle (`php-native`, `typescript`).
- `detect` : une condition vraie suffit. Clés disponibles : `files_any` (présence de fichiers à la racine du sous-projet), `composer_require_any` (`require` et `require-dev`), `package_json_any` (`dependencies` et `devDependencies`), `headers_any` (texte dans les 30 premières lignes d'un fichier, ex. `{ file: style.css, header: "Theme Name:" }`).
- Les signaux doivent être **propres** au profil : `composer.json` seul désigne `php-native`, pas `laravel`.

## 3. Les 7 sections

Titres exacts, tous obligatoires, dans cet ordre :

| Section | Lue par |
|---|---|
| `## Conventions` | `dev-implement`, `reviewer-quality`, `review-challenger`, `convention-detector` |
| `## Architecture` | `architect`, `code-mapper`, `cartographer`, planners, `dev-plan`, `dev-implement` |
| `## Testing` | `test-writer`, `gate-checker` |
| `## Security` | `security-analyst`, `reviewer-security`, `risk-mapper` |
| `## Data & migrations` | planners, `dev-plan`, `reviewer-bugs`, `risk-mapper` |
| `## Simplification` | `dev-simplifier` |
| `## Tooling` | `gate-checker`, `/devflow:init` |

Règles d'écriture :
- un point = une règle vérifiable (« pas de requête Eloquent dans un contrôleur »), pas un conseil général ; extrait de code de 3 lignes au plus ;
- section sans différence avec le parent : écrire `_inherit_` seul ;
- sinon, les points de l'enfant **complètent** ceux du parent ; pour annuler un point du parent, écrire `**Remplace** : <point du parent> → <nouvelle règle>` ;
- la section `Conventions` liste les codes de debug interdits (utilisés par G1, critère `no_debug_code`) ;
- la section `Tooling` donne les commandes que `/devflow:init` proposera pour `tooling.*`.

Exemple (extrait) :

```markdown
# Profil laravel

> Étend `php-native`. Laravel ≥ 10. Ne décrit que les différences propres à Laravel.

## Conventions
- Contrôleurs fins : validation dans une `FormRequest`, logique dans un service ou une action.
- Pas de `dd()`, `dump()`, `ray()` dans le code commité.

## Architecture
_inherit_

## Testing
- **Remplace** : PHPUnit seul → PHPUnit ou Pest selon `composer.json` ; `RefreshDatabase` pour les tests qui touchent la base.

## Security
- Pas d'affectation de masse sans `$fillable` ; `{!! !!}` dans Blade seulement sur une valeur déjà échappée.

## Data & migrations
- Toute modification de schéma passe par une migration avec `down()` ; pas de `DB::statement` sans requête préparée.

## Simplification
_inherit_

## Tooling
- Tests : `php artisan test` ; lint : `vendor/bin/pint --test` ; analyse statique : `vendor/bin/phpstan analyse` (Larastan).
```

## 4. Détection dans `/devflow:init`

`/devflow:init` lit l'en-tête de chaque profil et retient le profil **le plus profond** de la chaîne `extends` dont une condition `detect` est vraie : un projet avec `laravel/framework` donne `laravel`, pas `php-native`. Vérifiez dans [commands/init.md](../commands/init.md) s'il faut compléter :
- étape 1, point 2 : la liste des fichiers qui signalent un sous-projet (si le profil introduit un nouveau fichier marqueur) ;
- étape 2 : la table d'outillage (commandes de tests, lint, analyse statique) ;
- étape 3 : les signaux du mode `legacy` propres à la stack (version minimale, structure).

Ajoutez aussi le profil à la liste en commentaire de [templates/config.yml](../templates/config.yml) et au tableau des stacks du [README](../README.md).

## 5. Tester avec `/devflow:rules`

Dans un projet de test qui contient un `.devflow/config.yml` avec un bloc `profile: laravel` :

```bash
/devflow:rules reviewer-quality app/Http/Controllers/OrderController.php
/devflow:rules test-writer tests/Feature/OrderTest.php
/devflow:rules gate-checker
```

Vérifiez : la chaîne `php-native` → `laravel`, lue du parent vers l'enfant ; seules les sections du rôle sont lues ; les `_inherit_` et les « Remplace » sont appliqués.

## 6. Fixture, ticket et cases d'éval

Voir [evals/README.md](../evals/README.md) et [ADR 0006](adr/0006-native-evals.md).

1. **Fixture** : `evals/_fixtures/laravel-app/`, projet témoin minimal et statique (quelques fichiers suffisent), avec `.devflow/config.yml`, `.devflow/conventions.md` et `CLAUDE.md`. Ajoutez `evals/_fixtures/claude-v0/laravel-app.md` si un case utilise `--no-devflow`. Lancez `php -l` sur les fichiers PHP.
2. **Ticket** : `evals/tickets/laravel-modern-feature-01.md` (en-tête `id`, `project`, `profile`, `mode`, `task_type`, `size`, `milestone` ; critères attendus).
3. **Cases**, au minimum :
   - `init-laravel` : `/devflow:init --yes` détecte `laravel` (scaffold `laravel-app --no-devflow`, grader `regex` sur `.devflow/config.yml`) ;
   - `rules-laravel-reviewer-quality` : `/devflow:rules` lit `laravel.md` et `php-native.md` section par section (graders `tool_used` sur Read et `llm`) ;
   - `laravel-feature-01-analyse` : `dev-analyse` sur le ticket.

   Chaque case : `case.yaml` (`schema_version: "1.1"`), `scaffold.sh` qui appelle `../../_fixtures/scaffold.sh laravel-app [options]`, `prompt.md`, `graders/*.md`. Testez `scaffold.sh` à la main dans un dossier temporaire. Prenez `evals/cases/init-mixed/` et `evals/cases/rules-angular-reviewer-quality/` comme modèles.
4. Lancement :

```bash
claude plugin eval . --case '*laravel*' --scaffold --trust-plugin --no-publish --ablation none --allow-tools Write Edit
```

## 7. Vérifier

```bash
claude plugin validate . --strict   # doit afficher « Validation passed »
scripts/validate.sh                 # contrôles maison (en-tête et sections obligatoires des profils…)
tests/hooks/run.sh                  # si un hook est concerné
```

Ajoutez enfin une entrée au [CHANGELOG](../CHANGELOG.md) et, si le profil change une décision (héritage, règle transverse), un ADR à partir de [templates/adr.md](../templates/adr.md).
