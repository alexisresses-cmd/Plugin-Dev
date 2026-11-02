# Backlog

> Idées hors périmètre du jalon en cours. Rien ici n'est implémenté sans décision explicite.

## Décisions à prendre

- ~~ADR 0006 — évals natives~~ : accepté, voir `docs/adr/0006-native-evals.md`.
- Lecture du YAML par les hooks : parseur awk + valeurs par défaut sûres (ADR 0004), à implémenter au M3.

## v1.x (repris de la SPEC § 6)
- `/devflow:learn` : mise à jour de `conventions.md` à partir de `review-return` / `challenge-review`.
- Reprise d'un cycle interrompu (`.devflow/runs/<ticket>/state.json`, `/devflow:resume`).
- Vérification réelle : Docker / `wp-env`, migrations, contrôle navigateur Playwright.
- Phase livraison : revue des migrations, plan de retour arrière, checklist de déploiement, changelog.
- Type de tâche `upgrade` (Rector, dépréciations).
- Sources de tickets via connecteurs MCP (GitHub, ZenHub, Trello, Jira, Linear).

## Notes issues du M0 / M1
- Clé `git.base_branch` (la v0 code `main` / `master` en dur) ou détection via `origin/HEAD`.
- Garder `dev-cycle` sous forme de workflow `.js` de plugin plutôt qu'en skill : parallélisme et schémas JSON natifs, mais pas de dialogue avec l'utilisateur, ce qui empêche les checkpoints. À réévaluer après les mesures de tokens du M2.
- CI avec sandbox (bubblewrap + socat) pour exécuter les cases d'implémentation (M6).
- Icône et `README` ≥ 40 mots pour une éventuelle soumission à l'annuaire de plugins Anthropic.

## v2
- Autres langages / frameworks (Laravel, Python…), AngularJS 1.x.
