# Changelog

Format : [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/). Versionnage : [SemVer](https://semver.org/lang/fr/).

## [Unreleased]

## [0.2.0] — M2 : extraction des agents

### Ajouté
- 13 agents de plugin (table 3.5 de la SPEC), avec outils, modèle et format de sortie structuré : `business-analyst`, `code-mapper` (haiku), `architect` (opus), `security-analyst`, `planner-dev`, `planner-cto`, `plan-challenger` (opus), `test-writer`, `reviewer-quality`, `reviewer-bugs` (opus), `reviewer-security` (opus), `review-challenger` (opus), `gate-checker` (haiku).
- `knowledge/RESOLVER.md` (version M2) : procédure de chargement des règles commune à tous les agents.
- Hook `restrict-agents.sh` : les reviewers et le challenger ne peuvent lancer que des commandes git de lecture (66 tests au total).
- `dev-cycle --checkpoints` : remplace le mode Orchestra.
- Évals : cases `symfony-feature-01-plan` et `symfony-feature-01-review` (CI), fixtures `analyses/` et `patches/`.
- CI GitHub Actions : `ci.yml` (validation et tests des hooks à chaque push), `evals.yml` (évals manuelles avec sandbox).
- ADR 0007 : `dev-plan` rédige le plan lui-même, seul le challenger est délégué.

### Modifié
- `dev-analyse`, `dev-plan`, `dev-review`, `dev-test`, `challenge-review` deviennent des orchestrateurs légers. Les rapports complets vont dans le fichier d'analyse, plus dans la conversation.
- `dev-cycle` est réécrit en skill : il enchaîne `dev-implement`, G1, `dev-test`, `dev-review` (challenge + G2) et `dev-pr`, avec 2 corrections maximum par gate.
- Les gates G1 et G2 sont évaluées par `gate-checker`, et non plus par l'agent qui a produit le code.
- Le fichier d'analyse a un en-tête YAML (`task_type`, `security_audit`, `status`).
- Pour un bugfix, l'analyse recommande le correctif minimal.

### Supprimé
- Workflows JS `dev-cycle-run` et `dev-review-run`, et les dossiers `prompts/` des skills (intégrés aux agents).

## [0.1.0] — M1 : squelette du plugin

### Ajouté
- Manifestes `.claude-plugin/plugin.json` (devflow 0.1.0) et `marketplace.json` (`alexis-plugins`, le repo est sa propre marketplace).
- Skills migrés de la v0 à fonctionnalités égales (périmètre PHP) : `dev-analyse`, `dev-plan`, `dev-cycle`, `dev-implement`, `dev-test`, `dev-review`, `challenge-review`, `dev-pr`, `review-return`.
- `dev-commit` devient un skill avec un mode `--auto` : seul point d'application du format de commit, appelé par tous les autres skills et workflows.
- `dev-copilot` : traitement des retours GitHub Copilot, construit sur `review-return` (nouvelle option `--reviewer`).
- Commande `dev-branch`.
- Workflows de plugin `dev-cycle-run` et `dev-review-run` (renommés pour éviter la collision avec les skills).
- Agent `dev-simplifier` (réécrit).
- Hooks : `block-secrets.sh`, `block-dangerous.sh` (reprise des règles `deny` de la v0), `no-comments.sh` (actif par défaut) ; 51 tests dans `tests/hooks/run.sh`.
- `knowledge/core/clean-code.md` et `knowledge/stacks/php-native.md` (provisoire).
- Évals natives (ADR 0006) : fixture `symfony-api`, cases `symfony-feature-01-analyse`, `symfony-bugfix-01-analyse`, `hook-block-secrets`.

### Corrigé (par rapport à la v0)
- Le workflow `dev-cycle` contenait une erreur de syntaxe JS qui l'empêchait de s'exécuter.
- Formats de commit écrits en dur dans `dev-implement` et les workflows : remplacés par l'appel à `dev-commit`.
- `php-conventions` n'était lu par aucun skill : `dev-implement` lit désormais `php-native.md`.

### Supprimé
- `install.sh`, `update.sh` (remplacés par la marketplace) ; préférences perso de `settings.json`.

## [0.0.0] — M0 : préparation
- Initialisation du dépôt : README, licence MIT, `.gitignore` (`_source/`), CHANGELOG.
- `docs/SPEC.md` : copie figée des sections 1 à 4 du plan.
- `docs/source-inventory.md` : destination de chaque fichier du repo v0 et passages spécifiques à PHP.
- ADR 0001 (mécanique des plugins, résultats des spikes), 0002 (trois axes), 0003 (héritage des profils), 0004 (`.devflow/`), 0005 (skill orchestre / agent exécute).
- `docs/backlog.md`, dont la proposition d'ADR 0006 (évals natives).
- `evals/` : README et 10 tickets de référence sur des projets témoins fictifs.
