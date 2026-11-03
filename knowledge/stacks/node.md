---
profile: node
extends: typescript
detect:
  files_any: []
  composer_require_any: []
  package_json_any: [express, fastify, koa, "@hapi/hapi"]
---

# Profil node

> Étend `typescript`. Serveur Node.js (Express, Fastify, Koa ; Node ≥ 18). Ne décrit que les différences propres au back-end.

## Conventions
- Handlers `async` ; toute erreur asynchrone remonte au gestionnaire d'erreurs du framework (Express 4 : `next(err)` ou wrapper ; Express 5 / Fastify : `throw`).
- Configuration lue une seule fois au démarrage dans un module dédié (`config.ts`), validée (schéma) et typée ; pas de `process.env.X` dispersé dans le code applicatif.
- Journalisation par un logger structuré (`pino`, `winston`) ; pas de `console.*` dans le code applicatif.

## Architecture
- Couches séparées : route / contrôleur (lecture de la requête, réponse) → service (logique métier) → accès aux données (repository). Pas de requête en base dans un handler.
- Validation des entrées (corps, paramètres, query) à l'entrée de la route par un schéma (`zod`, schéma JSON Fastify) ; le service reçoit des données typées et validées.
- Un gestionnaire d'erreurs central traduit les erreurs métier en codes HTTP (400 validation, 401, 403, 404, 409) ; les erreurs inattendues donnent 500 sans détail interne.
- Arrêt propre : fermeture du serveur et des connexions sur `SIGTERM`.

## Testing
- Routes HTTP : **Supertest** sur l'application (sans écouter de port) ; statut, corps et en-têtes vérifiés.
- Contrôle d'accès : un test par cas (anonyme 401, interdit 403, autorisé 2xx) ; validation : un test 400 par règle importante.
- Base de test isolée (conteneur, base en mémoire ou transaction annulée) ; jamais la base de développement.

## Security
- **Injection SQL / NoSQL** : requêtes paramétrées ou query builder / ORM ; jamais de concaténation ; pour MongoDB, refuser les objets d'opérateur (`$gt`, `$where`) dans les entrées.
- **CORS** : liste blanche d'origines explicite ; jamais `origin: '*'` avec `credentials: true`.
- **En-têtes** : `helmet` (ou équivalent) ; `x-powered-by` désactivé.
- **Rate limiting** sur l'authentification et les routes coûteuses (`express-rate-limit`, `@fastify/rate-limit`).
- Taille des corps bornée (`express.json({ limit })`, `bodyLimit`) ; uploads : type MIME vérifié sur liste blanche, taille bornée, nom régénéré.
- Mots de passe : `argon2` ou `bcrypt` ; jetons comparés en temps constant (`crypto.timingSafeEqual`).
- `child_process` : jamais avec une entrée non validée ; `execFile` avec arguments plutôt que `exec`.
- Erreurs : aucune pile ni message interne renvoyé au client en production.

## Data & migrations
- Schéma modifié par une migration versionnée de l'ORM (Prisma `migrate`, TypeORM, Knex, Drizzle) ; jamais de `synchronize: true` hors développement.
- Colonnes ajoutées sur une table existante : nullables ou avec valeur par défaut.
- Opérations liées dans une transaction ; requêtes dans une boucle (N+1) à signaler.

## Simplification
_inherit_

## Tooling
- Tests d'API : `supertest` avec le framework de test du parent.
- Démarrage : script `start` / `dev` de `package.json`.
- Migrations : `npx prisma migrate dev` / `npx prisma migrate deploy`, `npx typeorm migration:run`, selon l'ORM présent.
