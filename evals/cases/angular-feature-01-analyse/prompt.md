---
runs: 1
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Agent, Write]
expected_outcome: "Analyse Angular : RxJS debounceTime/distinctUntilChanged/switchMap, toSignal ou takeUntilDestroyed, OnPush/signals, label et aria-live, pas d'innerHTML, Vitest + Playwright."
---
/devflow:dev-analyse #31 — Ajouter un champ de recherche sur la liste des produits : filtre côté serveur (`GET /api/products?q=`), saisie temporisée de 300 ms, état « aucun résultat ».
