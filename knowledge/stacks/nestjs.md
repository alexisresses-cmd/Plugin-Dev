---
profile: nestjs
extends: node
detect:
  files_any: [nest-cli.json]
  composer_require_any: []
  package_json_any: ["@nestjs/core"]
---

# Profil nestjs

> Étend `node` (donc `typescript`). NestJS ≥ 10. Ne décrit que les différences propres à NestJS.

## Conventions
- Un dossier par module fonctionnel (`src/tasks/`) : `tasks.module.ts`, `tasks.controller.ts`, `tasks.service.ts`, `dto/create-task.dto.ts`, `entities/` ou modèle Prisma ; fichiers générés par `nest g` ou au même format.
- Injection par le constructeur (`private readonly tasksService: TasksService`) ; jamais d'instanciation `new` d'un provider.
- **Remplace** : configuration dans `config.ts` → `@nestjs/config` (`ConfigModule.forRoot` avec schéma de validation, `ConfigService` injecté).
- **Remplace** : logger structuré → `Logger` de `@nestjs/common` (ou `nestjs-pino` si présent).

## Architecture
- **Modules** : chaque fonctionnalité dans son module ; un module n'exporte que les providers utilisés ailleurs ; pas d'import circulaire (`forwardRef` = signal de découpage à revoir).
- **Contrôleurs fins** : décorateurs de route, DTO en entrée, appel au service, retour typé. Pas d'accès aux données ni de logique métier dans un contrôleur.
- **DTO** de requête en classes avec décorateurs **class-validator** (`@IsString()`, `@MaxLength(120)`, `@IsBoolean()`, `@IsOptional()`, `@IsDateString()`) et `class-transformer` si besoin (`@Type(() => Date)`) ; DTO de mise à jour via `PartialType` (`@nestjs/mapped-types` ou `@nestjs/swagger`).
- **`ValidationPipe` global** dans `main.ts` (et dans l'application des tests e2e) : `new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true })`.
- **Guards** pour l'authentification et l'autorisation (`CanActivate`, `@UseGuards`, global via `APP_GUARD`) ; rôles par décorateur (`@Roles('admin')` + `Reflector`). Jamais de contrôle d'accès dans le corps d'un handler.
- **Exceptions HTTP** de `@nestjs/common` (`NotFoundException`, `ConflictException`, `UnauthorizedException`, `ForbiddenException`) levées par le service ou traduites par un filtre (`@Catch`) ; pas de `res.status()` manuel.
- Intercepteurs pour les préoccupations transverses (sérialisation `ClassSerializerInterceptor`, journalisation, délai), pas pour la logique métier.
- Accès aux données via un provider dédié (repository TypeORM injecté par `@InjectRepository`, ou `PrismaService` encapsulé dans un module).

## Testing
- **Remplace** : framework du parent → **Jest** (préconfiguré par `nest new`) sauf si le projet a migré vers Vitest.
- Unitaires : `Test.createTestingModule({ providers: [TasksService, { provide: PrismaService, useValue: mock }] })` ; un test par règle métier et par exception levée.
- **e2e** (`test/*.e2e-spec.ts`, `jest-e2e.json`) : `Test.createTestingModule({ imports: [AppModule] })`, `app.useGlobalPipes(<même ValidationPipe que main.ts>)`, **Supertest** sur `app.getHttpServer()` ; cas 2xx, 400 (champ manquant, champ inconnu rejeté par `forbidNonWhitelisted`), 401/403 (guard), 404.
- Base de test isolée (schéma Prisma de test, transaction annulée ou conteneur) ; jamais la base de développement.

## Security
- `ValidationPipe` global avec `whitelist` et `forbidNonWhitelisted` : un DTO sans décorateur de validation sur un champ est un défaut (le champ serait accepté sans contrôle ou supprimé).
- Guard global ou par contrôleur sur toute route non publique ; routes publiques marquées explicitement (`@Public()`). Secret attendu (clé d'API, JWT) lu par `ConfigService` et comparé en temps constant.
- Réponses : entités sérialisées via DTO de sortie ou `@Exclude()` (`ClassSerializerInterceptor`) ; jamais de mot de passe, jeton ou champ interne exposé.
- Paramètres de route typés et convertis par pipe (`ParseIntPipe`, `ParseUUIDPipe`) ; propriété de la ressource vérifiée dans le service ou un guard (IDOR).
- Requêtes brutes (`$queryRaw`, `query()`) : paramètres liés uniquement (`Prisma.sql` / gabarit balisé, `$1`), jamais `$queryRawUnsafe` avec une entrée.

## Data & migrations
- **Prisma** : modification de `schema.prisma` + migration générée (`npx prisma migrate dev --name <nom>`) commitée dans `prisma/migrations/` ; `npx prisma generate` après modification.
- **TypeORM** : migration générée (`typeorm migration:generate`) avec `down()` ; `synchronize: false` hors développement.
- Champ optionnel du DTO ⇔ colonne nullable (`DateTime?`) : nullabilité cohérente entre DTO, modèle et migration.
- Erreurs de contrainte de la base (Prisma `P2002` unicité, `P2025` introuvable) traduites en `ConflictException` / `NotFoundException`.

## Simplification
- DTO dérivés (`PartialType`, `PickType`, `OmitType`) plutôt que des classes recopiées.
- Supprimer un pipe ou une validation manuelle redondante avec le `ValidationPipe` global.
- Ne pas créer de module, d'interface ou de provider abstrait pour une seule implémentation.

## Tooling
- Tests : `npm test` (Jest unitaires), `npm run test:e2e`, `npm run test:cov` (couverture).
- Génération : `npx nest g resource <nom>` (ou `module`, `controller`, `service`).
- Lint : `npm run lint` (ESLint de `nest new`) ; typage : `npx tsc --noEmit -p tsconfig.json`.
