# Changelog

Format : [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/). Versionnage : [SemVer](https://semver.org/lang/fr/).

## [Unreleased]

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
