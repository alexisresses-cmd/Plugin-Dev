# ADR 0006 — Tickets de référence exécutés avec `claude plugin eval`

- **Statut :** accepté (validé par Alexis le 2026-11-02)
- **Date :** 2026-11-02
- **Réf. SPEC :** D6, 3.10 — remplace le mode d'exécution manuel prévu en 3.10

## Contexte

La SPEC prévoit des tickets de référence en Markdown, exécutés à la main, avec un rapport rédigé à la main. Claude Code fournit `claude plugin eval`, qui exécute des cases isolés, les note avec des graders et compare chaque résultat à une exécution sans le plugin.

## Décision

```
evals/
├── tickets/<id>.md              # spécification lisible du ticket (inchangée)
├── _fixtures/
│   ├── scaffold.sh              # copie une fixture dans le workspace + git init
│   └── <fixture>/               # projet témoin statique (ex. symfony-api)
├── cases/<id>-<phase>/          # case natif : prompt.md, case.yaml, scaffold.sh, graders/
└── results/
    ├── YYYYMMDD-vX.Y.md         # rapport de jalon (commité)
    └── <horodatage>/            # sorties brutes de `claude plugin eval` (ignorées par git)
```

- Un ticket donne un case **par phase évaluée** (`-analyse`, `-plan`, `-cycle`…). Les critères du ticket deviennent des graders :
  - `tool_used` : le bon skill ou le bon agent a été appelé ;
  - `file_exists` : les fichiers attendus ont été produits ;
  - `regex` : critère vérifiable textuellement (y compris une absence) ;
  - `llm` : critère qualitatif, rédigé en conditions PASS / FAIL précises.
- Les projets témoins fictifs sont des **fixtures statiques** copiées par `scaffold.sh` (rapide, reproductible, sans réseau).
- Commande de référence : `claude plugin eval . --scaffold --trust-plugin --no-publish [--case <glob>] [--ablation none]`.
- `--ablation none` pour les cases qui invoquent explicitement `/devflow:…` (la comparaison sans plugin n'a pas de sens). Comparaison activée pour les cases en langage naturel et les hooks.

## Limites connues

- Les runs sont isolés : pas de `CLAUDE.md` chargé automatiquement (nos skills le lisent explicitement, donc sans impact) ni de réseau ; `gh` est indisponible. Les étapes « draft PR » / « PR ready » ne sont pas évaluables : les cases s'arrêtent avant.
- Accorder `Bash` exige le sandbox OS (bubblewrap + socat sous Linux). L'environnement de développement actuel n'en dispose pas : les cases qui implémentent du code (Bash requis pour git, PHPUnit) tourneront en CI (M6) ou sur un poste équipé.
- Chaque run est un appel modèle réel, facturé. Les cases d'analyse coûtent environ 1 $ par run (voir rapports).

## Conséquences

- Les métriques de la SPEC (critères OK/KO, coût, gates au premier essai) viennent du JSON de résultat (`--json`).
- Le rapport de jalon reste un Markdown court, qui renvoie aux résultats bruts.
