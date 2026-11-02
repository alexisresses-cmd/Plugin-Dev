# ADR 0004 — Configuration du projet dans `.devflow/`

- **Statut :** accepté (un point ouvert, à trancher en M3)
- **Date :** 2026-11-02
- **Réf. SPEC :** D5, 3.1

## Contexte

En v0, la configuration (`BRANCH_PREFIX`, `COMMIT_FORMAT`, `ISSUE_TRACKER`, `MAIN_REVIEWER`) et les conventions du projet sont mêlées dans `CLAUDE.md`, en texte libre. Les hooks ne peuvent pas lire ce format de façon fiable, et les préférences personnelles se retrouvent imposées à l'équipe.

## Décision

```
.devflow/
├── config.yml          # commité : stacks, tooling, git, tracker, pipeline, hooks
├── config.local.yml    # gitignoré : surcharges personnelles (fusion profonde)
├── conventions.md      # conventions observées et validées (priorité maximale, D2)
└── project-map.md      # cartographie (produite par /devflow:discover)
```

- Priorité : valeurs par défaut du plugin < `config.yml` < `config.local.yml`.
- `CLAUDE.md` du projet ne contient qu'une section `## devflow` avec des imports (`@.devflow/conventions.md`…), ajoutée par `/devflow:init` sans écraser l'existant.
- Les préférences d'Alexis (`dev-simplifier` systématique, `hooks.no_comments: true`) vont dans **son** `config.local.yml`.
- `schema_version: 1` permet de faire évoluer le schéma.
- Correspondance avec la v0 : `BRANCH_PREFIX` → `git.branch_prefix`, `COMMIT_FORMAT` → `git.commit_format`, `ISSUE_TRACKER` → `issue_tracker`, `MAIN_REVIEWER` → `git.main_reviewer`.

## Point ouvert (M3) — lecture du YAML par les hooks

`read-config.sh` doit lire `hooks.*` et `stacks[].wordpress.protected` sans dépendance garantie (`yq` n'est pas installé partout). Options :

1. **Parseur awk minimal** limité aux clés lues par les hooks (sans dépendance ; fragile si le YAML devient complexe).
2. **`yq` si présent, sinon valeurs par défaut sûres** (`block_secrets: true`, `no_comments: false`) et avertissement.
3. **Cache JSON** `.devflow/.resolved.json` régénéré par `/devflow:init` et lu avec `jq` (ou `grep`) ; risque de décalage si l'utilisateur modifie le YAML à la main.

Recommandation provisoire : **1 + valeurs par défaut sûres**, car les hooks ne lisent que quelques clés plates.

## Conséquences

- La configuration devient lisible par une machine et versionnée.
- Il faudra un guide de migration depuis `CLAUDE.md` v0 (`docs/migration-from-v0.md`, M6).
