# Conventions du projet

## Nommage
- Fichiers en kebab-case suffixés par leur rôle (`*.module.ts`, `*.controller.ts`, `*.service.ts`, `*.dto.ts`), comme le code généré par `nest new`.

## Architecture
- Un module Nest par domaine métier sous `src/<domaine>/` (aucun pour l'instant).
- Accès aux données via Prisma (`prisma/schema.prisma`, PostgreSQL) ; `DATABASE_URL` vient de l'environnement.

## Données
- Migrations générées par `prisma migrate dev`, commitées dans `prisma/migrations/`.

## Sécurité

## Tests
- Jest : tests unitaires `src/**/*.spec.ts`, e2e `test/*.e2e-spec.ts` (Supertest). Dépendances non installées dans cet environnement : les commandes `tooling` n'y tournent pas.

## Pièges connus

## Incohérences observées
