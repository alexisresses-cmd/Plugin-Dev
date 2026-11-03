# Shop

Monorepo de la boutique : `api/` (API REST Symfony 7.2, PHP 8.3, Doctrine, MariaDB) et `front/` (administration Angular 19, standalone, signals, Vitest).

## Conventions Git

```
BRANCH_PREFIX: feat/
COMMIT_FORMAT: conventional
ISSUE_TRACKER: text
MAIN_REVIEWER: @alexis
```

## Conventions spécifiques au projet

- Chaque DTO PHP de `api/src/Dto/` a son miroir TypeScript dans `front/src/app/products/product.ts`.
- La validation qui fait foi est celle de l'API (contraintes `Assert`), le front n'en est que le reflet.
- Prix en centimes (`priceInCents`).
