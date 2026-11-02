---
name: dev-commit
description: >
  Prépare et crée un commit propre au format du projet (lu dans CLAUDE.md). Seul point du
  plugin où le format de commit est appliqué : tous les autres skills l'invoquent.
  Mode interactif par défaut (propose, attend la validation) ou --auto (commite sans
  confirmation et retourne le hash). Déclencher pour tout commit : "commite", "fais le commit".
argument-hint: "[--auto] [ticket-id] [-- contexte]"
---

# dev-commit — Préparation du commit

Tu es un développeur senior qui prépare un commit propre et bien documenté.

## Arguments

`$ARGUMENTS`

- `--auto` : mode non interactif (appel depuis un autre skill). Aucune question, aucune attente de validation.
- `ticket-id` (optionnel) : identifiant du ticket à faire apparaître dans le message.
- `-- contexte` (optionnel) : texte libre qui précise l'objet du commit (ex. `-- correction gate G1`).

## Contexte du projet

Lis le `CLAUDE.md` à la racine du projet pour connaître :
- `COMMIT_FORMAT` : `conventional` ou format custom décrit dans CLAUDE.md
- `BRANCH_PREFIX` : pour extraire l'identifiant du ticket depuis le nom de branche

## Numéro de ticket

Si un identifiant est fourni en argument, il doit apparaître dans le message de commit.
Sinon, extrais-le du nom de la branche courante.
Si aucun identifiant n'est trouvable :
- **interactif** : demande à l'utilisateur avant de continuer ;
- **--auto** : commite sans identifiant et signale-le dans le retour.

## Ce que tu dois faire

### 1. Vérification de la branche

`git branch --show-current`

Si la branche est `main`/`master` : **stoppe** (dans les deux modes). Il ne faut pas committer directement sur la branche principale.

### 2. Analyse des changements

`git diff --staged`. Si rien n'est stagé : `git status` et `git diff`.

### 3. Staging

- Identifie les fichiers qui font partie de ce commit.
- Signale les fichiers qui semblent hors scope (à exclure ou à committer séparément).
- **interactif** : propose la commande `git add` et attends la validation.
- **--auto** : stage uniquement les fichiers liés au contexte ; laisse les fichiers hors scope non stagés et liste-les dans le retour. Ne stage jamais un fichier de secrets (`.env*`, `*.pem`, `*.key`…).

### 4. Message de commit

**Si `COMMIT_FORMAT: conventional`** ou absent : Conventional Commits.

```
type(scope): #{id} description courte en impératif
```

Types : `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `style`.
Scope : nom du module ou fichier principal touché.
Sans identifiant : `type(scope): description`.

**Si format custom** : applique le format décrit dans CLAUDE.md.

Règles du message :
- Le message décrit le « pourquoi », pas seulement le « quoi ».
- Un seul sujet par commit : si les changements couvrent plusieurs sujets, propose de découper (interactif) ou fais plusieurs commits (--auto).
- Description à l'impératif présent : « Ajoute », « Corrige », « Supprime ».

**interactif** : présente le message et attends la validation avant `git commit`.
**--auto** : commite directement.

### 5. Push

Une fois le commit effectué, si la branche a un upstream : `git push`. La PR draft est déjà ouverte, le push la met à jour.

### 6. Retour

**--auto** : termine par une ligne exploitable par l'appelant :

```
COMMIT <hash-court> <message>
```

Une ligne par commit créé, puis `UNSTAGED <fichier>` pour chaque fichier laissé de côté.
