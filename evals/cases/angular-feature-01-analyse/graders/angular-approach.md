---
type: llm
focus: last_message
---
PASS si le rapport final (ou le résumé de l'analyse qu'il contient) couvre AU MOINS 4 de ces 5 points :
1. Recherche temporisée en RxJS : `debounceTime(300)`, `distinctUntilChanged` et `switchMap` (annulation de la requête précédente), avec le paramètre `q` passé par `ProductService` (`HttpParams`), pas par `HttpClient` dans le composant.
2. Désabonnement via `toSignal` ou `takeUntilDestroyed`, sans `subscribe` imbriqué.
3. Composant en OnPush avec signals, cohérent avec `ProductListComponent` existant.
4. Accessibilité : `label` associé au champ et annonce du nombre de résultats ou de l'état « aucun résultat » via `aria-live`.
5. Tests : Vitest du composant (`HttpTestingController`, temps simulé) et un scénario Playwright.
FAIL si l'analyse propose `innerHTML` ou `bypassSecurityTrust*`, un filtrage côté client à la place du filtre serveur, ou ne mentionne aucun de ces points.
