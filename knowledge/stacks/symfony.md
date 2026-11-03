---
profile: symfony
extends: php-native
detect:
  files_any: [symfony.lock, bin/console, config/bundles.php]
  composer_require_any: [symfony/framework-bundle]
  package_json_any: []
---

# Profil symfony

> Étend `php-native`. Ne décrit que les différences propres à Symfony (≥ 5.4 ; attributs PHP 8 si le projet les utilise).

## Conventions
- Services autowirés et autoconfigurés ; injection par le constructeur (propriétés `private readonly`). Pas d'appel au conteneur (`$this->container->get`) dans le code nouveau.
- Routes, sécurité et mapping Doctrine en **attributs** si le projet les utilise déjà, sinon dans le format existant (YAML / annotations).
- Classes dans les dossiers conventionnels : `Controller/`, `Service/`, `Repository/`, `Entity/`, `Form/`, `Security/Voter/`, `EventSubscriber/`, `Message/` + `MessageHandler/`.
- Paramètres de configuration via `%env()%` / `services.yaml`, jamais `$_ENV` ou `getenv` dans le code applicatif.

## Architecture
- **Contrôleurs fins** : lecture de la requête, appel d'un service, réponse. Pas de logique métier, pas de requête Doctrine dans un contrôleur.
- Logique métier dans des services ; accès aux données via les Repositories (`QueryBuilder` / DQL), jamais `EntityManager::getConnection()` avec du SQL brut sans raison documentée.
- Autorisation dans des **Voters** (`#[IsGranted]` ou `denyAccessUnlessGranted`), jamais par test de rôle dans un contrôleur.
- Validation par contraintes (`Assert\…`) sur les entités ou les DTO ; formulaires via `Form` pour les écrans HTML.
- Traitements asynchrones ou lents : **Messenger** (message + handler).
- Événements du domaine : `EventSubscriber` plutôt que listeners déclarés en YAML pour le code nouveau.

## Testing
- Unitaires : `PHPUnit\Framework\TestCase`. Intégration : `KernelTestCase`. Contrôleurs : **`WebTestCase`** (`static::createClient()`, `assertResponseStatusCodeSame`).
- Contrôle d'accès : un test par rôle pertinent (anonyme 401, utilisateur 403, administrateur 2xx).
- Données : fixtures ou factories (Foundry) si présentes ; base de test isolée (`.env.test`, `dama/doctrine-test-bundle` si présent).

## Security
- **CSRF** : actif sur les formulaires Symfony ; jeton vérifié (`isCsrfTokenValid`) pour les actions POST hors formulaire.
- `access_control` dans `security.yaml` pour les grandes zones ; **Voters** pour les règles sur une ressource (propriété, état).
- Sérialisation : groupes (`#[Groups]`) explicites pour ne pas exposer de champs sensibles dans les réponses JSON.
- Twig échappe par défaut : `|raw` interdit sur une donnée utilisateur.
- `ParamConverter` / `MapEntity` : vérifier l'autorisation sur l'entité résolue, pas seulement l'authentification.

## Data & migrations
- Toute modification de mapping Doctrine s'accompagne d'une **migration** (`doctrine:migrations:diff`), relue, avec `down()` fonctionnel.
- Colonnes ajoutées sur une table existante : nullables ou avec valeur par défaut.
- Requêtes de liste : `QueryBuilder` avec pagination ; éviter le N+1 (jointures `addSelect`).
- `flush()` une fois par cas d'usage, dans le service, pas dans une boucle.

## Simplification
- Remplacer une récupération manuelle de service ou de paramètre par l'injection.
- Supprimer un `ParamConverter` explicite quand la résolution automatique suffit.
- Utiliser les helpers d'`AbstractController` (`json`, `createNotFoundException`) plutôt que de construire les réponses à la main.

## Tooling
- Tests : `vendor/bin/phpunit` (ou `bin/phpunit` si `symfony/phpunit-bridge`).
- Lint : `bin/console lint:container`, `bin/console lint:twig templates/`, `bin/console lint:yaml config/` en plus du lint PHP.
- Schéma : `bin/console doctrine:schema:validate --skip-sync`.
- Analyse statique : PHPStan avec `phpstan/phpstan-symfony` et `phpstan/phpstan-doctrine` si installés.
