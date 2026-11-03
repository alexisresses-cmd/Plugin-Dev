---
id: angular-modern-feature-01
project: fixture:angular-app
profile: angular
mode: modern
task_type: feature
size: M
milestone: M5
---
## Projet témoin
Angular 19, composants standalone, signals, OnPush, routes en lazy loading, Vitest, Playwright. Service `ProductService` (HttpClient).

## Ticket
Ajouter un champ de recherche sur la liste des produits : filtre côté serveur (`GET /api/products?q=`), saisie temporisée de 300 ms, état « aucun résultat ».

## Critères attendus
- [ ] Recherche temporisée avec RxJS (`debounceTime`, `distinctUntilChanged`, `switchMap`) ; désabonnement via `takeUntilDestroyed` ou `toSignal`.
- [ ] Composant OnPush / signals, pas de `subscribe` imbriqué.
- [ ] Accessibilité : `label` associé, annonce du nombre de résultats (`aria-live`).
- [ ] Aucun `innerHTML` ni `bypassSecurityTrust*`.
- [ ] Tests Vitest du composant + scénario Playwright.
