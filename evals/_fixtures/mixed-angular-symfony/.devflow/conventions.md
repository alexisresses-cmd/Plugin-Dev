# Conventions du projet

## Nommage
- API : PSR-4 `App\`, un DTO par sens (`api/src/Dto/ProductInput.php` en écriture, `ProductOutput.php` en lecture).
- Front : un dossier par fonctionnalité (`front/src/app/products/`), écrans d'administration sous `admin/`.

## Architecture
- Contrat d'API : chaque DTO PHP a son miroir TypeScript dans `front/src/app/products/product.ts` (`Product` ↔ `ProductOutput`, `ProductInput` ↔ `ProductInput`), mêmes noms de champs en camelCase.
- API : contrôleurs fins, `#[MapRequestPayload]` sur le DTO d'entrée, écriture dans `api/src/Service/ProductWriter.php`. Routes d'écriture sous `/api/admin`, réservées à `ROLE_ADMIN`.
- Front : composants standalone OnPush, `inject()`, formulaires réactifs typés (`NonNullableFormBuilder`), appels HTTP dans `ProductService` uniquement.

## Données
- Prix en centimes (`priceInCents`, `int`). Migrations Doctrine dans `api/migrations/`.

## Sécurité
- La validation qui fait foi est celle de l'API (contraintes `Assert` sur le DTO d'entrée, réponse 422). Les validateurs Angular n'en sont que le reflet.

## Tests
- API : PHPUnit 11, WebTestCase (`api/tests/`). Front : Vitest (`*.spec.ts` à côté du composant). Dépendances non installées dans cet environnement : `tooling` à `null`.

## Pièges connus

## Incohérences observées
