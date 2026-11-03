# ADR 0001 — Mécanique des plugins Claude Code (spikes M0)

- **Statut :** accepté (en attente de validation par Alexis)
- **Date :** 2026-11-02
- **Version testée :** Claude Code 2.1.316

## Contexte

La section 4 de la SPEC liste 7 points techniques à vérifier avant de construire le plugin. Chacun a été vérifié dans la doc officielle (`code.claude.com/docs/en/plugins-reference`, `plugins/components`, `plugins/marketplace-reference`, `hooks`, `sub-agents`, `plugin-evals`), puis par un plugin minimal chargé avec `claude -p --plugin-dir` : un skill, un agent, une commande et un hook `PreToolUse` qui journalise son entrée.

## Résultats

| # | Question | Résultat | Preuve |
|---|---|---|---|
| 1 | Format de `plugin.json` / `marketplace.json`, validation | `plugin.json` : seul `name` est requis ; `version`, `description`, `author.name`, `license` sont recommandés (sinon warning). `marketplace.json` : `name`, `owner.name`, `plugins[]` requis ; entrée `{ "name": "devflow", "source": "./" }` pour un repo qui est sa propre marketplace. Validation : `claude plugin validate . [--strict]` | Spike : `Validation passed` sur les deux fichiers |
| 2 | `${CLAUDE_PLUGIN_ROOT}` dans skills, agents, commandes, hooks | **Oui partout.** Substitué inline dans le Markdown des skills / commandes / agents ; exporté en variable d'environnement aux hooks (avec `CLAUDE_PLUGIN_DATA`, `CLAUDE_PROJECT_DIR`). **Absent** de l'environnement des commandes Bash lancées par Claude | Spike : skill et agent ont lu `${CLAUDE_PLUGIN_ROOT}/knowledge/probe.md` |
| 3 | Frontmatter des agents | Champs pris en compte : `name`, `description`, `model` (`sonnet`/`opus`/`haiku`/`fable`/ID complet/`inherit`), `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `omitClaudeMd`, `isolation`, `color`. **Ignorés pour un agent de plugin** : `permissionMode`, `hooks`, `mcpServers`, `initialPrompt`. **`tools: Bash(git diff:*)` ne restreint pas** : l'agent reçoit l'outil Bash complet | Spike : l'agent `tools: Read, Bash(git diff:*)` déclare disposer de Bash |
| 4 | Règles de permission (`deny`) dans un plugin | **Impossible.** Le `settings.json` d'un plugin n'accepte que `agent` et `subagentStatusLine`, les autres clés sont ignorées | Doc « Default settings » |
| 5 | `hooks/hooks.json` et entrée des scripts | Fichier `{ "hooks": { "<Event>": [ { "matcher": "Edit\|Write", "hooks": [ { "type": "command", "command": "\"${CLAUDE_PLUGIN_ROOT}\"/…" } ] } ] } }`. Stdin JSON : `tool_name`, `tool_input.file_path` (Read/Edit/Write), `tool_input.command` (Bash), `cwd`, `permission_mode`, `hook_event_name`, et **`agent_type` / `agent_id` quand l'appel vient d'un sous-agent**. Blocage : `exit 2` + stderr, ou JSON `hookSpecificOutput.permissionDecision: "deny"`. Les hooks du plugin **s'appliquent aussi dans les sous-agents** | Spike : journal du hook, appel du sous-agent avec `"agent_type":"devflow:prober"` |
| 6 | Préfixe des skills / commandes | `skills/<dir>/SKILL.md` → `/devflow:<dir>` ; `commands/<f>.md` → `/devflow:<f>` ; agent → `devflow:<name>` (invocable par l'outil Agent et `@agent-devflow:<name>`) | Spike : `devflow:probe`, `devflow:hello`, agent `devflow:prober` listés |
| 7 | Lecture hors projet via `${CLAUDE_PLUGIN_ROOT}` | **Oui**, par le skill comme par l'agent (Read accepté hors du dossier du projet) | Spike : contenu lu par les deux |

## Écarts avec la SPEC et décisions

1. **D4 — « un agent ne peut pas lancer d'autres agents »** : faux aujourd'hui (imbrication possible sur 3 niveaux, réglable via `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`). **Décision : on conserve D4 comme règle de conception** (orchestration uniquement depuis les skills : plus simple à tracer, coûts maîtrisés). Les agents devflow n'auront pas l'outil `Agent` dans `tools`. La seconde contrainte (pas de validation depuis un agent) est confirmée : `AskUserQuestion` est retiré à tous les sous-agents.
2. **Table 3.5 — outils « lecture + `git diff` »** : la restriction par commande est impossible dans `tools`. **Décision :** les reviewers déclarent `tools: Read, Grep, Glob, Bash`, et `block-dangerous.sh` refuse toute commande Bash autre que `git diff|log|show|status|blame` quand `agent_type` vaut `devflow:reviewer-*`, `devflow:review-challenger`, `devflow:code-mapper`… (liste des agents en lecture seule tenue dans le script). Même principe pour `gate-checker` : seules les commandes `tooling.*` de la config sont autorisées.
3. **`deny` de l'ancien `settings.json`** : confirmé, portés par `block-dangerous.sh` (prévu en 3.8).
4. **Commandes vs skills** : la doc présente `commands/` comme l'ancien format. Sans impact fonctionnel, on garde `commands/init.md`, `discover.md`, `dev-branch.md` comme prévu. `dev-commit` devient un skill (il est invoqué par d'autres skills).
5. **Workflows** : un plugin peut embarquer `workflows/*.js` (format utilisé par `dev-cycle` / `dev-review` dans la source). En M1, on les reprend tels quels pour garantir l'égalité fonctionnelle, puis la SPEC (3.6) les remplace par l'orchestration en skill en M2. Alternative consignée dans `docs/backlog.md`.
6. **Évals natives** : `claude plugin eval` existe et lit par défaut `evals/**/prompt.md|case.yaml` + `graders/*.md`, avec un `scaffold_script` pour créer un projet témoin et une comparaison automatique sans plugin. Le format `evals/tickets/*.md` de la SPEC ne crée pas de conflit (il ne contient ni `prompt.md` ni `case.yaml`). **Proposition soumise à Alexis : ADR 0006** (voir `docs/backlog.md`).
7. **`${CLAUDE_PLUGIN_ROOT}` absent du Bash de Claude** : un skill qui doit lancer un script du plugin écrit le chemin dans son Markdown (il y est substitué), il ne s'appuie jamais sur la variable d'environnement.
8. **Lecture de la config dans les hooks** : `read-config.sh` ne peut pas compter sur `yq`. Décision reportée au M3 (ADR 0004).

## Conséquences

- Aucun point n'invalide l'architecture. Deux ajustements : restriction des commandes par hook (point 2), maintien volontaire de D4 (point 1).
- `claude plugin validate . --strict` sera exécuté dans la CI (M6) en plus des contrôles maison.
- Le validateur réclame un `README.md` d'au moins 40 mots et une icône pour une soumission à l'annuaire Anthropic. L'icône est hors périmètre v1 (backlog).
