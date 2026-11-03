---
id: nest-greenfield-feature-01
project: fixture:nest-greenfield
profile: nestjs
mode: greenfield
task_type: feature
size: M
milestone: M5
---
## Projet témoin
Projet NestJS 11 tout juste généré (`nest new`), TypeScript strict, Prisma configuré (PostgreSQL), Jest. Aucun module métier.

## Ticket
Créer le module `tasks` : CRUD de tâches (`title` requis ≤ 120 car., `done` booléen, `dueDate` optionnelle), protégé par un guard qui exige un en-tête `x-api-key`.

## Critères attendus
- [ ] ADR rédigé pour les choix structurants (organisation des modules, validation, gestion d'erreurs).
- [ ] DTO + `ValidationPipe` global (`whitelist`, `forbidNonWhitelisted`) + class-validator.
- [ ] Migration Prisma générée.
- [ ] Tests unitaires du service + e2e (`Test.createTestingModule`, Supertest) ; objectif de couverture du mode greenfield atteint.
- [ ] Aucun `any` non justifié ; `tsc --noEmit` et ESLint verts.
