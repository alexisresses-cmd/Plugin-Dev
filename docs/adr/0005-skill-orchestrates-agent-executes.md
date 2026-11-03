# ADR 0005 — Le skill orchestre, l'agent exécute

- **Statut :** accepté
- **Date :** 2026-11-02
- **Réf. SPEC :** D4, 3.5, 3.6 — voir aussi ADR 0001 (points 1 et 2)

## Contexte

En v0, les prompts des sous-agents sont des fichiers `agents/*.md` lus par le skill, puis passés à un sous-agent générique. Le modèle et les outils ne sont pas contrôlés, et `dev-cycle` / `dev-review` dépendent de scripts Workflow installés hors du repo.

## Décision

| | Skill | Agent (`agents/*.md` du plugin) |
|---|---|---|
| Contexte | conversation principale | isolé |
| Dialogue / validation utilisateur | oui | **non** (`AskUserQuestion` indisponible) |
| Git / GitHub (branche, commit, PR) | oui | non (sauf écriture de fichiers pour `test-writer` et `dev-simplifier`) |
| Lance d'autres agents | oui, en parallèle | **non, par convention** (pas d'outil `Agent` dans `tools`) |
| Modèle / outils | ceux de la session | fixés dans le frontmatter |
| Sortie | message à l'utilisateur, fichiers | **format structuré** (JSON ou Markdown à sections fixes) |

- Chaque agent commence par appliquer `${CLAUDE_PLUGIN_ROOT}/knowledge/RESOLVER.md` pour sa section.
- Format commun des findings de review : `{ id, severity: blocking|should-fix|note, file, line, issue, fix, rule_source }`.
- Les commandes Bash autorisées aux agents « lecture seule » sont filtrées par hook selon `agent_type` (ADR 0001, point 2).
- `dev-implement` reste un skill : l'utilisateur peut corriger en cours de route.
- Le mode « Orchestra » de la v0 devient `dev-cycle` avec `pipeline.checkpoints: true`.

## Conséquences

- Modèle par agent (haiku pour `code-mapper` / `gate-checker`, opus pour `architect` / `reviewer-bugs` / `reviewer-security` / challengers) : coût maîtrisé, mesuré en M2.
- Les sorties structurées rendent les gates automatisables (`gate-checker` → `{gate, status, reasons[]}`).
- Les scripts Workflow de la v0 disparaissent à partir de M2.
