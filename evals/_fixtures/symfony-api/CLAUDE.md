# Catalog API

API REST du catalogue produits (Symfony 7.2, PHP 8.3, Doctrine ORM, MariaDB).

## Conventions Git

```
BRANCH_PREFIX: feat/
COMMIT_FORMAT: conventional
ISSUE_TRACKER: text
MAIN_REVIEWER: @alexis
```

## Conventions spécifiques au projet

- Contrôleurs fins : la logique métier va dans `src/Service/`.
- Toute autorisation passe par un Voter (`src/Security/Voter/`), jamais de `in_array($role, ...)` dans un contrôleur.
- Les requêtes de liste passent par le Repository (QueryBuilder), jamais de filtrage PHP après chargement.
- Montants en centimes (`int`) dans le domaine. Exception historique : `OrderTotalCalculator`.
- Tests : PHPUnit 11, WebTestCase pour les contrôleurs. PHPStan niveau 8.
