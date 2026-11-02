---
description: Crée manuellement la branche Git d'un ticket selon git.branch_prefix (secours si /devflow:dev-plan ne l'a pas fait)
argument-hint: "<ticket-id> [sujet]"
---

# dev-branch — Création manuelle de la branche de développement

> **Note** : Dans le workflow normal, la branche est créée automatiquement par `/devflow:dev-plan` après approbation du plan.
> Ce command est un **outil de secours** à utiliser si tu as besoin de créer une branche manuellement.

Tu es un développeur senior en charge de créer la branche Git liée à un ticket.

## Ticket

$ARGUMENTS

## Convention de nommage

Lis `.devflow/config.yml` (puis `.devflow/config.local.yml`, qui l'emporte). Absent : demande de lancer `/devflow:init` et arrête-toi. Utilise `git.branch_prefix` (défaut `feat/`) et `git.base_branch` (défaut `main`).

Format du nom de branche :

```
{branch_prefix}{ticket-id}-{slug-kebab-case}
```

Exemples selon la config :
- `feat/42-user-profile-upload`
- `fix/123-login-session-timeout`
- `TEAM/TB#42-user-profile-upload`

Règles :
- `{ticket-id}` = numéro/identifiant fourni en argument
- Le slug est en **kebab-case**, max 5 mots, décrivant le sujet du ticket

## Ce que tu dois faire

1. Lire la configuration (`git.branch_prefix`, `git.base_branch`)
2. Vérifier la branche courante : `git branch --show-current`
3. Si on n'est pas sur `git.base_branch`, afficher un avertissement et demander confirmation
4. Faire un `git pull` pour être à jour
5. Proposer un nom de branche basé sur l'argument et la convention
6. Créer et checkout la branche
7. Confirmer avec `git branch --show-current`

## Format de sortie

```
Branche de départ : main
Branche créée     : feat/42-user-profile-upload
Checkout          : ✅
```
