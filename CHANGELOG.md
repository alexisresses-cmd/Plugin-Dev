# Changelog

Format : [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/). Versionnage : [SemVer](https://semver.org/lang/fr/).

## [Unreleased]

## [0.5.0] — M5 : TypeScript et projets mixtes

### Ajouté
- Profils `typescript`, `node` (`extends: typescript`), `nestjs` (`extends: node`) et `angular` (`extends: typescript`) ; détection par `files_any` et `package_json_any`.
- Critères de review front dans `angular` : accessibilité, performance, RxJS.
- Projets mixtes : chaque fichier suit le profil et le mode de son bloc `stacks[]` ; règle du contrat d'API (`knowledge/core/api-contract.md`), chargée seulement quand le périmètre couvre plusieurs blocs : contrat mis à jour des deux côtés dans le même ticket, ordre contrat → serveur → client, validation serveur obligatoire, divergence = `blocking`.
- `/devflow:init` : un bloc `stacks[]` par sous-projet, signaux de mode et outillage TypeScript.
- `dev-analyse` : champ « Profils » et, en mixte, « Contrat d'API » ; `dev-plan` : profil indiqué par tâche en mixte.
- Fixtures `nest-greenfield`, `angular-app`, `mixed-angular-symfony` ; 8 nouveaux cases.
- ADR 0009.

### Modifié
- Mode `greenfield` : chaque tâche du plan inclut ses tests.

## [0.4.0] — M4 : legacy et WordPress

### Ajouté
- `/devflow:discover` : trois agents en parallèle (`cartographer`, `convention-detector`, `risk-mapper`) produisent `.devflow/project-map.md` et un brouillon de `.devflow/conventions.md` (section « Incohérences observées »), validés avant écriture ; option `--yes`.
- Profil `wordpress` (`extends: php-native`) : WPCS, hooks, thème enfant, sécurité (nonce, capacités, échappement, `$wpdb->prepare`), tests ; détection par `headers_any` (en-têtes `Theme Name:` / `Plugin Name:`).
- Bloc `wordpress` dans `.devflow/config.yml` (`type`, `protected`) et hook `protect-paths.sh` : toute modification du cœur, du thème parent ou d'une extension tierce est refusée ; `config.local.yml` ne peut qu'ajouter des chemins.
- `/devflow:init` détecte WordPress (type, thème parent) et suggère `/devflow:discover` en mode legacy.
- `dev-analyse` transmet l'état de la carte du projet aux agents.
- Fixture `wp-legacy-theme` ; 6 nouveaux cases (discover ×2, WordPress feature, refactor, init, hook).

### Modifié
- `tasks/refactor.md` : une seule transformation par tâche du plan.

## [0.3.0] — M3 : configuration et résolution des règles

### Ajouté
- `.devflow/config.yml` + `config.local.yml` (fusion profonde) ; modèles dans `templates/` (`config.yml`, `conventions.md`, `CLAUDE.snippet.md`, `adr.md`).
- `/devflow:init` : détection des profils (champ `detect`), de l'outillage, du mode (signaux justifiés), des conventions git ; reprise des clés v0 de `CLAUDE.md` ; options `--yes` et `--greenfield`.
- `knowledge/RESOLVER.md` complet : table des rôles, chaîne `extends`, lecture section par section, priorité D2.
- Profils `php-native` (réécrit, 7 sections) et `symfony` (`extends: php-native`) ; `_template.md`.
- Modes `legacy`, `modern`, `greenfield` et types de tâche `feature`, `bugfix`, `refactor` (8 sections par phase).
- Skill `/devflow:rules` : affiche les règles chargées pour un rôle (test du RESOLVER).
- Triage S/M/L dans `dev-analyse` ; voie rapide (S) dans `dev-cycle` ; planners réservés à la taille L.
- Gate G0 (tests de caractérisation avant un refactor) ; règle du cliquet en mode legacy.
- `hooks/scripts/read-config.sh` ; hooks `block_secrets` et `no_comments` configurables (`no_comments` désactivé par défaut).
- Fixture `php-legacy-shop` ; 10 nouveaux cases (RESOLVER, init, legacy, voie rapide, G0).
- ADR 0008.

### Modifié
- Tous les skills lisent `.devflow/config.yml` (`git.*`, `issue_tracker`, `pipeline.*`) au lieu de `CLAUDE.md`.
- `gate-checker` utilise `tooling.*` et gère G0, G1, G2.
- `block-secrets` (Bash) : analyse limitée aux commandes qui manipulent des fichiers, sans faux positifs sur les heredocs, messages de commit et `echo`.

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
