---
profile: php-native
extends: null
detect:
  files_any: [composer.json, index.php]
  composer_require_any: []
  package_json_any: []
---

# Profil php-native

> Socle PHP commun à tous les profils PHP (Symfony et WordPress l'étendent). PHP ≥ 7.4 ; les règles marquées 8+ ne s'appliquent que si la version du projet le permet (`composer.json` → `require.php`).

## Conventions
- Style **PSR-12** : 4 espaces, accolade de classe et de méthode à la ligne, une instruction par ligne, 120 caractères max, pas de `?>` final.
- **PSR-4** : un fichier par classe, namespace = arborescence.
- `declare(strict_types=1);` dans tout nouveau fichier si le projet l'utilise déjà.
- Typage des paramètres, des retours et des propriétés sur tout code nouveau ou modifié (`?Type` plutôt que `null|Type` si < 8.0).
- Visibilité toujours explicite ; `final` par défaut sur les nouvelles classes sans héritage prévu (8+ : propriétés `readonly` pour les dépendances injectées).
- Ordre dans une classe : constantes, propriétés, constructeur, méthodes publiques, protégées, privées.
- Nommage : `PascalCase` (classes), `camelCase` (méthodes, variables), `UPPER_SNAKE_CASE` (constantes) ; booléens `is/has/can…`.
- Code de debug interdit dans le diff : `var_dump`, `print_r`, `dd`, `dump`, `die`, `exit` hors point d'entrée, `error_log` de diagnostic.
- Comparaisons strictes (`===`, `in_array(..., true)`).

## Architecture
- Séparer présentation, logique métier et accès aux données, même sans framework : un fichier de page ne contient pas de SQL nouveau.
- Dépendances injectées (constructeur) plutôt qu'instanciées dans les méthodes ou lues dans des globales.
- Gestion d'erreurs : exceptions métier dédiées (`App\Exception\…`) ; erreurs système journalisées (PSR-3 si disponible) et jamais affichées à l'utilisateur.
- Configuration lue depuis l'environnement ou un fichier de config, jamais en dur dans le code.
- **Legacy typique** (à respecter, pas à refondre hors périmètre) : `include`/`require` en cascade, variables globales (`$db`, `$config`), SQL dans les vues, fonctions préfixées. Un nouveau code s'insère dans ces patterns s'ils sont la convention observée.

## Testing
- Framework : **PHPUnit** si présent (`vendor/bin/phpunit`, `phpunit.xml*`). Tests dans `tests/`, miroir de `src/`, classe `<Classe>Test`, une méthode `test<Comportement>` par cas.
- Sans framework : scripts PHP autonomes selon `${CLAUDE_PLUGIN_ROOT}/skills/dev-test/references/php-test-patterns.md` (`tests/test_<Classe>.php`, `exit(1)` en cas d'échec).
- Logique pure (validation, calcul, formatage) : tests automatisés. SQL direct, `$_SESSION`, `$_FILES`, `header()`, rendu HTML : plan de test manuel si aucune infrastructure de test n'existe.
- Données de test explicites ; jamais de base réelle ni de réseau dans un test unitaire.

## Security
- **Injection SQL** : requêtes préparées (PDO `prepare` + paramètres nommés, ou `mysqli` + `bind_param`) ; jamais de concaténation d'une entrée. Identifiants dynamiques (colonne, tri) : liste blanche.
- **XSS** : toute sortie échappée au plus près de l'affichage (`htmlspecialchars($v, ENT_QUOTES, 'UTF-8')`).
- **Entrées** : validation côté serveur (`filter_input`, contrôles de type et de bornes) ; jamais de confiance dans un champ caché ou un contrôle JavaScript.
- **CSRF** : jeton vérifié sur tout POST qui modifie des données ; aucune écriture sur un GET.
- **Contrôle d'accès** : rôle **et** propriété de la ressource vérifiés côté serveur (IDOR).
- **Upload** : `UPLOAD_ERR_OK`, MIME réel (`finfo` / `mime_content_type`) sur liste blanche, taille bornée par une constante, nom régénéré, `move_uploaded_file`, stockage hors webroot ou non exécutable.
- **Sessions** : `session_regenerate_id(true)` après connexion ou changement de privilège ; cookies `HttpOnly`, `Secure`, `SameSite`.
- **Interdits** : `eval`, `unserialize` d'une entrée, `extract($_REQUEST)`, `shell_exec`/`exec`/`system` avec une entrée, `include` d'un chemin dérivé d'une entrée.
- Mots de passe : `password_hash` / `password_verify` uniquement.

## Data & migrations
- Toute modification de schéma est un script versionné et réversible (ou un script de retour arrière documenté).
- Opérations multi-requêtes liées : transaction.
- Types : montants en entiers (centimes) ou `bcmath`, jamais en `float` ; dates en UTC, `DateTimeImmutable`.
- Vérifier la cohérence des types PHP / colonnes (longueur, nullabilité) : pas de troncature silencieuse.
- Requêtes dans une boucle (N+1) : à signaler.

## Simplification
- Early return plutôt qu'imbrication ; suppression des `else` après `return`.
- Remplacer une conversion ou une vérification redondante avec le typage (`(int)` sur un `int`, `isset` sur une valeur garantie).
- 8+ : `match` plutôt qu'un `switch` qui retourne une valeur ; opérateur `?->` et `??` plutôt que des `if` de nullité.
- Ne jamais ajouter d'abstraction (interface, factory) pour un usage unique.

## Tooling
- Tests : `vendor/bin/phpunit` (ou `php tests/test_*.php` sans framework).
- Lint : `vendor/bin/phpcs` (standard PSR12), `vendor/bin/php-cs-fixer fix --dry-run --diff`, sinon `php -l <fichier>`.
- Analyse statique : `vendor/bin/phpstan analyse --no-progress` ou `vendor/bin/psalm` ; baseline : `phpstan-baseline.neon` / `psalm-baseline.xml`.
- Détection de la version : `require.php` de `composer.json`, sinon `php -v`.
