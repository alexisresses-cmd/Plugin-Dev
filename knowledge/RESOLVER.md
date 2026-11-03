# RESOLVER — Chargement des règles

> Procédure commune aux agents et aux skills devflow (SPEC § 3.2). Chaque appelant l'applique **avant sa mission**, pour **son rôle** dans la table ci-dessous.
> Objectif : économiser les tokens. On ne lit jamais un fichier de règles en entier, seulement les sections de son rôle.

`K` = `${CLAUDE_PLUGIN_ROOT}/knowledge`

## Table des rôles

| Rôle | Section de profil (`K/stacks/*.md`) | Section de mode et de tâche (`K/modes/*.md`, `K/tasks/*.md`) | `K/core/clean-code.md` | `K/core/api-contract.md` (projet mixte) |
|---|---|---|---|---|
| `dev-analyse` (synthèse) | Architecture, Testing | `analyse` | non | oui |
| `business-analyst` | — | `analyse` | non | non |
| `code-mapper` | Architecture | `analyse` | non | oui |
| `architect` | Architecture | `analyse` | non | oui |
| `security-analyst` | Security | `analyse` | non | non |
| `cartographer` | Architecture | `analyse` | non | non |
| `convention-detector` | Conventions | `analyse` | non | non |
| `risk-mapper` | Security, Data & migrations | `analyse` | non | non |
| `dev-plan`, `planner-dev`, `planner-cto`, `plan-challenger` | Architecture, Data & migrations | `plan` | non | oui |
| `dev-implement` | Conventions, Architecture | `implement` | oui | oui |
| `test-writer` | Testing | `test` | non | oui |
| `reviewer-quality` | Conventions | `review` | oui | non |
| `reviewer-bugs` | Data & migrations | `review` | non | oui |
| `reviewer-security` | Security | `review` | non | non |
| `review-challenger` | Conventions | `review` | non | oui |
| `gate-checker` | Testing, Tooling | `gates` | non | non |
| `dev-simplifier` | Simplification | `simplifier` | oui | non |
| `dev-pr` | — | `pr` | non | non |

Les rôles de `/devflow:discover` (`cartographer`, `convention-detector`, `risk-mapper`) n'ont pas de ticket : ils ne lisent pas de section de type de tâche.

## Procédure

1. **Configuration.** Lis `.devflow/config.yml`, puis `.devflow/config.local.yml` s'il existe : ses clés remplacent celles de `config.yml` (fusion profonde).
   - Absente : un **skill** s'arrête et demande de lancer `/devflow:init`. Un **agent** renvoie `{ "error": "missing_config", "detail": "lancer /devflow:init" }` et s'arrête.
2. **Type de tâche.** Lis `task_type` (et `size`) dans l'en-tête du fichier `analysis/*.md` fourni, sinon dans le message de l'appelant. À défaut : `feature`.
3. **Profils concernés.** Prends les fichiers du périmètre : diff de la branche (`git diff <base>...HEAD --name-only`), fichiers listés dans l'analyse, ou fichiers que tu vas toucher. Associe chaque fichier au bloc `stacks[]` dont le `path` est le plus long préfixe du fichier ; à défaut, au premier bloc. Un ticket peut concerner plusieurs profils : charge les règles de chacun (étapes 4 et 5) et applique **à chaque fichier celles de son bloc** (profil et mode), jamais celles d'un autre bloc. Dans ta sortie, indique le profil quand une règle ou un finding en dépend.
4. **Chaîne d'héritage.** Pour chaque profil, lis l'en-tête de `K/stacks/<profil>.md` (`extends`), puis remonte jusqu'à `extends: null`. Pour chaque section de ton rôle, lis-la **du parent vers l'enfant** :
   - `_inherit_` dans l'enfant : la section du parent s'applique sans ajout ;
   - un point de l'enfant qui dit « remplace » annule le point correspondant du parent ; sinon, l'enfant **complète** le parent.
5. **Mode et tâche.** Lis la section de ton rôle (`## <phase>`) dans `K/modes/<mode du profil>.md` et dans `K/tasks/<task_type>.md`.
6. **Projet.** Lis `.devflow/conventions.md` (en entier) s'il existe. Pour les rôles de phase `analyse` ou `plan` (table ci-dessus), lis aussi `.devflow/project-map.md` s'il existe (produit par `/devflow:discover`) : c'est un point de départ échantillonné, à vérifier dans le code.
7. **Principes génériques.** Si la colonne `clean-code` vaut « oui », lis `K/core/clean-code.md`.
   **Projet mixte.** Si le périmètre couvre au moins deux blocs `stacks[]` et que la colonne `api-contract.md` de ton rôle vaut « oui », lis dans `K/core/api-contract.md` la section de ta phase (même nom que pour le mode). Ticket mono-bloc : ne le lis pas.
8. **Priorité en cas de conflit**, de la plus forte à la plus faible (SPEC D2) :
   1. `.devflow/conventions.md`
   2. `K/core/api-contract.md` (projet mixte)
   3. `K/tasks/<type>.md`
   4. `K/modes/<mode>.md`
   5. `K/stacks/<profil>.md` (enfant, puis parent)
   6. `K/core/clean-code.md`

   En mode `legacy`, **les conventions observées dans le code priment sur les conventions idéales** de la stack.

## Lire une seule section

Repère les titres avec Grep (`^## `, option `-n`) sur le fichier, puis lis avec Read de la ligne du titre jusqu'à la ligne précédant le titre suivant (`offset` / `limit`). N'utilise jamais Read sans `limit` sur un fichier de `K/stacks`, `K/modes` ou `K/tasks`.

## Traçabilité

Dans ta sortie, renseigne `rule_source` (findings) ou cite la source d'une règle quand elle tranche une décision : `conventions`, `task`, `mode`, `stack`, `core`.

## Règles communes à tous les agents

- Tu travailles seul : tu ne poses aucune question à l'utilisateur et tu ne lances aucun autre agent. S'il te manque une information, note-la dans ta sortie (`questions` ou `warnings`).
- Tu n'affirmes rien que tu n'as pas vérifié dans le code : cite les fichiers (et les lignes quand c'est utile).
- Tu respectes **exactement** le format de sortie de ton prompt : l'appelant l'analyse automatiquement.
