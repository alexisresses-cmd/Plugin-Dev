---
type: llm
focus: last_message
---
PASS si toutes ces conditions sont vraies dans le rapport :
1. Le fichier est associé au profil `angular` en mode `modern`, avec la chaîne d'héritage `angular` → `typescript` ; les sections sont lues du parent (`typescript`) vers l'enfant (`angular`).
2. La section de profil lue est `Conventions` (pour typescript et angular), et aucune autre section de profil n'est listée comme lue.
3. Les sections `review` de `modes/modern.md` et de `tasks/feature.md` sont listées (type de tâche par défaut : feature) ; `core/clean-code.md` est lu ; `core/api-contract.md` n'est pas lu (un seul bloc `stacks[]`).
4. Les règles déterminantes citent au moins une règle de chacun des trois critères de review front du profil angular : accessibilité (ex. `label` associé, `aria-live`, focus, clavier, contraste), performance (ex. OnPush, `track` dans `@for`, lazy loading, pas de calcul dans le gabarit) et RxJS (ex. pas de `subscribe` imbriqué, `switchMap` / `debounceTime` / `distinctUntilChanged`, `takeUntilDestroyed` / `toSignal` / pipe `async`).
FAIL sinon.
