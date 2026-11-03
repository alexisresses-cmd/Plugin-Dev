---
profile: typescript
extends: null
detect:
  files_any: [tsconfig.json]
  composer_require_any: []
  package_json_any: [typescript]
---

# Profil typescript

> Socle commun à tous les profils TypeScript (`node`, `nestjs` et `angular` l'étendent ; aussi le JavaScript des blocs Gutenberg d'un projet WordPress). TypeScript ≥ 5. Version et options lues dans `package.json` et `tsconfig.json`.

## Conventions
- `tsconfig.json` en `"strict": true` ; tout nouveau code compile sans relâcher une option stricte (`noImplicitAny`, `strictNullChecks`). En legacy non strict : ne pas introduire d'erreur nouvelle sous `strict`.
- Pas de `any` non justifié : `unknown` + rétrécissement (garde de type, `instanceof`, schéma) ; un `any` inévitable porte un commentaire d'une ligne qui dit pourquoi (`// eslint-disable-next-line @typescript-eslint/no-explicit-any -- <raison>`).
- Pas d'assertion non nulle `!` ni de `as` pour faire taire le compilateur ; `as const` et `satisfies` autorisés.
- Paramètres et retours des fonctions exportées typés explicitement ; types de domaine nommés (`interface` pour un objet, `type` pour une union ou un alias).
- `const` par défaut, `let` si réassignation, jamais `var` ; `===` uniquement.
- Imports ES (`import` / `export`), pas de `require` dans le code TypeScript ; pas d'export par défaut si le projet ne les utilise pas.
- Nommage : `PascalCase` (types, classes, énumérations), `camelCase` (fonctions, variables), `UPPER_SNAKE_CASE` (constantes de module) ; fichiers en `kebab-case` (`product-list.component.ts`).
- Unions de littéraux (`'draft' | 'published'`) plutôt qu'`enum` si le projet n'utilise pas déjà les `enum`.
- Code de debug interdit dans le diff : `console.log`, `debugger`, `// @ts-ignore` (utiliser `// @ts-expect-error <raison>` si inévitable).
- Promesses toujours attendues ou retournées (`no-floating-promises`) ; `async`/`await` plutôt que des chaînes `.then()`.

## Architecture
- Un module = une responsabilité ; pas de dépendance circulaire entre modules (`import` croisé).
- Types partagés (contrats d'API, modèles) dans un fichier dédié (`*.model.ts`, `*.types.ts`, `dto/`), importés par le code qui les consomme, jamais redéclarés.
- Dépendances injectées (constructeur ou paramètre) plutôt qu'importées comme singletons mutables.
- Erreurs : classes d'erreur dédiées (`class NotFoundError extends Error`) ; jamais de `throw` d'une chaîne ; `catch (e: unknown)` puis rétrécissement.
- Données externes (HTTP, fichier, variable d'environnement) typées `unknown` jusqu'à leur validation.

## Testing
- Framework : **Vitest** si présent (`vitest` dans `devDependencies`), sinon **Jest** (`jest`, `ts-jest` ou `@swc/jest`). Ne pas en introduire un second.
- Fichiers `*.spec.ts` (ou `*.test.ts` selon l'existant) à côté du fichier testé ou dans `test/` selon la convention observée ; un `describe` par unité, un `it` par comportement.
- Pas de `any` dans les tests non plus ; doublures typées (`vi.fn<…>()`, `jest.Mocked<T>`).
- Pas de réseau, d'horloge ni d'aléa réels dans un test unitaire : `vi.useFakeTimers()` / `jest.useFakeTimers()`, doublures des clients HTTP.

## Security
- Toute donnée externe validée à l'exécution avant usage (le typage TypeScript disparaît à la compilation) : schéma (`zod`, `class-validator`) ou garde de type.
- Interdits : `eval`, `new Function`, `setTimeout` avec une chaîne, construction de requête SQL / NoSQL / commande shell par concaténation d'une entrée.
- Aucun secret dans le code ni dans un fichier commité (`.env` exclu) ; secrets lus depuis l'environnement.
- Dépendances : pas de nouveau paquet sans raison ; `npm audit` (ou équivalent) sans vulnérabilité haute nouvelle.

## Data & migrations
- Montants en entiers (centimes) ou décimaux en chaîne, jamais en `number` flottant pour un calcul monétaire ; dates en ISO 8601 UTC à l'échange.
- Nullabilité explicite dans les types (`T | null`, propriété optionnelle `?`) et cohérente avec la source (API, base) : pas de `!` pour masquer un `null` possible.
- `JSON.parse` et réponses HTTP : résultat `unknown`, validé avant usage.

## Simplification
- Supprimer les annotations redondantes avec l'inférence sur les variables locales (garder celles des API exportées).
- Chaînage optionnel `?.` et `??` plutôt que des `if` de nullité ; `Array.prototype` (`map`, `filter`, `some`) plutôt que des boucles d'accumulation.
- Early return plutôt qu'imbrication.
- Ne pas créer de type générique, d'interface ou de classe abstraite pour un usage unique.

## Tooling
- Typage : `npx tsc --noEmit` (ou `-p tsconfig.app.json` selon le projet).
- Lint : `npx eslint .` (config `eslint.config.*` ou `.eslintrc*`, `typescript-eslint`) ; formatage : `npx prettier --check .` si présent.
- Tests : `npx vitest run` ou `npx jest` (script `test` de `package.json` s'il existe : `npm test`).
- Gestionnaire de paquets d'après le verrou : `package-lock.json` → npm, `pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn.
- Version de Node : `engines.node` de `package.json`, `.nvmrc`, sinon `node -v`.
