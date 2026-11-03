# Conventions du projet

## Nommage
- Un dossier par fonctionnalité sous `src/app/<fonctionnalité>/` (ex. `src/app/products/`), fichiers `*.component.ts`, `*.service.ts`, `*.model.ts`, `*.routes.ts`.

## Architecture
- Composants standalone en `ChangeDetectionStrategy.OnPush` (règle ESLint `prefer-on-push-component-change-detection`).
- Injection par `inject()`, pas par le constructeur (ex. `src/app/products/product.service.ts`).
- État exposé en signals ; les Observables HTTP sont convertis par `toSignal` dans le composant (ex. `product-list.component.ts`).
- Routes de fonctionnalité chargées en lazy loading (`loadChildren` / `loadComponent`, `src/app/app.routes.ts`).
- Les appels HTTP passent par un service de la fonctionnalité, jamais par `HttpClient` dans un composant.

## Données
- Prix en centimes (`priceInCents`), formatés avec `CurrencyPipe` à l'affichage.

## Sécurité

## Tests
- Vitest (`*.spec.ts` à côté du composant, `HttpTestingController`) et Playwright (`e2e/`). Dépendances non installées dans cet environnement : les commandes `tooling` n'y tournent pas.

## Pièges connus

## Incohérences observées
