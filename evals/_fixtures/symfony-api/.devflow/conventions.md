# Conventions du projet

## Architecture
- Contrôleurs fins : la logique métier va dans `src/Service/`.
- Toute autorisation passe par un Voter (`src/Security/Voter/`), jamais de `in_array($role, ...)` dans un contrôleur.
- Les requêtes de liste passent par le Repository (QueryBuilder), jamais de filtrage PHP après chargement.

## Données
- Montants en centimes (`int`) dans le domaine. Exception historique : `OrderTotalCalculator`.

## Tests
- PHPUnit 11, WebTestCase pour les contrôleurs. PHPStan niveau 8 (dépendances non installées dans cet environnement : `tooling` à `null`).
