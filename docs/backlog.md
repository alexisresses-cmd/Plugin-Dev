# Backlog

> Idées hors périmètre du jalon en cours. Rien ici n'est implémenté sans décision explicite.

## Décisions à prendre

### ADR 0006 (proposé) — Tickets de référence au format `claude plugin eval`
Claude Code fournit `claude plugin eval` (cases `evals/<case>/prompt.md` + `graders/*.md`, `case.yaml` avec `scaffold_script` pour construire le projet témoin, mesure automatique contre une exécution sans plugin, rapport HTML/JSON, filtrage par coût).
- **Option A (SPEC)** : tickets Markdown dans `evals/tickets/`, exécution et rapport manuels dans `evals/results/`.
- **Option B (proposée)** : chaque ticket devient un case natif. Les critères deviennent des graders (`regex` sur les fichiers produits, `tool_used` pour vérifier qu'un skill ou un agent a été appelé, `file_exists`, `llm` pour les critères qualitatifs). Les projets témoins fictifs deviennent des `scaffold_script` qui génèrent un mini-repo. Les métriques « tokens » et « gates au premier essai » viennent du JSON de résultat.
- Limites de B : les runs sont isolés (pas de `gh`, pas de réseau par défaut) ; la création de PR doit donc être simulée ou exclue du case. Le `CLAUDE.md` du workspace n'est pas chargé, ce qui ne gêne pas puisque la config est dans `.devflow/`.
- Recommandation : **garder les tickets Markdown comme spécification lisible (M0) et les convertir en cases natifs au M1**, quand le plugin est chargeable.

## v1.x (repris de la SPEC § 6)
- `/devflow:learn` : mise à jour de `conventions.md` à partir de `review-return` / `challenge-review`.
- Reprise d'un cycle interrompu (`.devflow/runs/<ticket>/state.json`, `/devflow:resume`).
- Vérification réelle : Docker / `wp-env`, migrations, contrôle navigateur Playwright.
- Phase livraison : revue des migrations, plan de retour arrière, checklist de déploiement, changelog.
- Type de tâche `upgrade` (Rector, dépréciations).
- Sources de tickets via connecteurs MCP (GitHub, ZenHub, Trello, Jira, Linear).

## Notes issues du M0
- Clé `git.base_branch` (la v0 code `main` / `master` en dur) ou détection via `origin/HEAD`.
- Garder `dev-cycle` sous forme de workflow `.js` de plugin plutôt qu'en skill : parallélisme et schémas JSON natifs, mais pas de dialogue avec l'utilisateur, ce qui empêche les checkpoints. À réévaluer après les mesures de tokens du M2.
- Icône et `README` ≥ 40 mots pour une éventuelle soumission à l'annuaire de plugins Anthropic.

## v2
- Autres langages / frameworks (Laravel, Python…), AngularJS 1.x.
