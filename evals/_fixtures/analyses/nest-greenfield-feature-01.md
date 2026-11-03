---
ticket: "#7"
title: Module tasks (CRUD protégé par clé d'API)
date: 2026-11-02
task_type: feature
size: M
profiles: [nestjs]
security_audit: true
status: analysed
---

# Analyse — Module tasks (CRUD protégé par clé d'API)

## Ticket
#7 — Créer le module `tasks` : CRUD de tâches (`title` requis ≤ 120 car., `done` booléen, `dueDate` optionnelle), protégé par un guard qui exige un en-tête `x-api-key`.

## Vision métier
### Reformulation
Exposer une API REST de gestion de tâches, accessible uniquement aux clients qui présentent la clé d'API.
### Critères d'acceptation
- [ ] `POST /tasks`, `GET /tasks`, `GET /tasks/:id`, `PATCH /tasks/:id`, `DELETE /tasks/:id`.
- [ ] `title` obligatoire, 120 caractères au plus ; `done` booléen (faux par défaut) ; `dueDate` date ISO 8601 facultative.
- [ ] Sans en-tête `x-api-key` valide : 401 sur toutes les routes.
- [ ] Corps invalide ou champ inconnu : 400 avec le détail des erreurs.
- [ ] Tâche inexistante : 404.
### Questions ouvertes
- (mineure) Pagination de `GET /tasks` : hors périmètre, liste complète triée par date de création.

## Vision code
### Points d'entrée
- `src/main.ts` — bootstrap, aucun pipe global.
- `src/app.module.ts` — module racine, aucun module métier.
### Fichiers impactés
| Fichier | Action | Raison |
|---|---|---|
| prisma/schema.prisma | modifier | modèle `Task` |
| prisma/migrations/ | créer | migration initiale |
| src/prisma/prisma.service.ts, prisma.module.ts | créer | accès Prisma injectable |
| src/tasks/tasks.module.ts, tasks.controller.ts, tasks.service.ts | créer | module métier |
| src/tasks/dto/create-task.dto.ts, update-task.dto.ts | créer | validation class-validator |
| src/common/guards/api-key.guard.ts | créer | contrôle de `x-api-key` |
| src/main.ts | modifier | `ValidationPipe` global, guard global |
| src/app.module.ts | modifier | import de `TasksModule`, `PrismaModule`, `ConfigModule` |
| src/tasks/tasks.service.spec.ts, test/tasks.e2e-spec.ts | créer | tests unitaires et e2e |
| package.json | modifier | `class-validator`, `class-transformer`, `@nestjs/config`, `@nestjs/mapped-types` |
### Tests existants
`src/app.controller.spec.ts` et `test/app.e2e-spec.ts` générés par `nest new`.

## Vision architecture
### Recommandation
Projet greenfield : poser les fondations avant le module.
- Un module par domaine (`src/tasks/`), un module technique `src/prisma/` (PrismaService global) et `src/common/` (guard).
- Validation : DTO class-validator, `ValidationPipe` global (`whitelist`, `forbidNonWhitelisted`, `transform`) déclaré dans `main.ts` et dans le bootstrap des tests e2e.
- Erreurs : `NotFoundException` dans le service ; l'erreur Prisma `P2025` traduite en 404 par un filtre d'exception dédié.
- Guard `ApiKeyGuard` global (`APP_GUARD`), clé lue par `ConfigService` (`API_KEY`), comparaison à temps constant.
- Choix structurants à consigner dans un ADR (organisation des modules, validation, gestion d'erreurs).

## Vision sécurité
### Niveau global
🟠 — authentification par clé partagée, entrée utilisateur persistée.
### Risques
| Niveau | OWASP | Risque | Localisation | Mesure attendue |
|---|---|---|---|---|
| 🟠 | A07 | clé comparée avec `===` (timing) ou commitée | ApiKeyGuard | `timingSafeEqual`, clé dans l'environnement |
| 🟠 | A04 | champs non prévus acceptés (mass assignment) | DTO | `whitelist` + `forbidNonWhitelisted` |
| 🟡 | A05 | messages d'erreur Prisma exposés | filtre d'exception | réponse générique |

## Synthèse
**Reformulation** : CRUD de tâches protégé par clé d'API, sur un projet NestJS neuf.
**Approche recommandée** : ADR des fondations, PrismaModule, ValidationPipe global, guard global, module `tasks`, tests unitaires + e2e.
**Fichiers clés** : schema.prisma, main.ts, app.module.ts, src/tasks/, src/common/guards/api-key.guard.ts.
**Risques prioritaires** : 1. comparaison de la clé ; 2. validation stricte des DTO ; 3. fuite des erreurs Prisma.
**Questions bloquantes** : Aucune
**Feu vert** : ✅

<!-- PLAN — complété par /devflow:dev-plan -->
