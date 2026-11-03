# Tasks API

API REST de gestion de tâches (NestJS 11, TypeScript strict, Prisma + PostgreSQL, Jest). Projet tout juste généré : aucun module métier.

## Conventions Git

```
BRANCH_PREFIX: feat/
COMMIT_FORMAT: conventional
ISSUE_TRACKER: text
MAIN_REVIEWER: @alexis
```

## Conventions spécifiques au projet

- Un module Nest par domaine métier sous `src/<domaine>/`.
- Accès aux données via Prisma ; migrations commitées dans `prisma/migrations/`.
