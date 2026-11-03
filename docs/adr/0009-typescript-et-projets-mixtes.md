# ADR 0009 — Profils TypeScript et projets mixtes (M5)

- **Statut :** accepté
- **Date :** 2026-11-03
- **Réf. SPEC :** D3, 3.1, 3.2, 3.7, 3.9 ; ADR 0003, 0008

## Contexte

Le jalon M5 ajoute les profils `typescript`, `node`, `nestjs` et `angular`, et les projets mixtes (ex. `api/` Symfony + `front/` Angular). La SPEC 3.9 impose une règle de review pour les mixtes : un contrat d'API modifié l'est des deux côtés dans le même ticket. Les tickets de référence `angular-modern-feature-01`, `nest-greenfield-feature-01` et `mixed-modern-feature-01` fixent les comportements attendus.

## Décisions

1. **Héritage** : `typescript` (`extends: null`) → `node` → `nestjs` ; `typescript` → `angular` (ADR 0003). Détection par `files_any` (`tsconfig.json`, `nest-cli.json`, `angular.json`) et `package_json_any` (`typescript`, `express`, `fastify`, `@nestjs/core`, `@angular/core`) ; le profil le plus profond l'emporte.
2. **Critères de review front dans `angular.md` § Conventions** (accessibilité, performance, RxJS), section lue par `reviewer-quality` et `dev-implement` : le code est écrit et relu avec les mêmes critères. Les défauts de flux de données qui produisent des bugs (réponses obsolètes, fuite d'abonnement, nullabilité) sont dans § Data & migrations, lue par `reviewer-bugs`. Aucune colonne ni section nouvelle dans le contrat des profils.
3. **Contrat d'API dans `knowledge/core/api-contract.md`**, une section par phase (`analyse`, `plan`, `implement`, `test`, `review`), plutôt que dans chaque profil : la règle est commune à toutes les paires de stacks (DRY). Le RESOLVER le charge via une colonne de la table des rôles (`dev-analyse`, `code-mapper`, `architect`, rôles du plan, `dev-implement`, `test-writer`, `reviewer-bugs`, `review-challenger`), **seulement si le périmètre couvre au moins deux blocs `stacks[]`** : un ticket mono-profil ne lit rien de plus. Priorité : juste après `.devflow/conventions.md`, et non assouplie par le mode `legacy`.
4. **Règles par fichier** : dans un ticket mixte, un agent charge les règles de chaque profil et applique à chaque fichier celles de son bloc (profil et mode). La synthèse de `dev-analyse` ajoute les lignes « Profils » et, en mixte, « Contrat d'API » ; le plan indique le profil de chaque tâche et ordonne contrat → serveur → client.
5. **`/devflow:init`** : un bloc `stacks[]` par sous-projet ; la racine n'a de bloc que si elle contient du code applicatif (un `package.json` de workspaces seul n'en produit pas). La règle greenfield (moins de 5 fichiers source) s'évalue par sous-projet.
6. **`tooling` reste global** (pas de `tooling` par bloc) : une commande par clé, lancée depuis la racine ; en mixte, les commandes des sous-projets sont enchaînées en sous-shells, `"(cd api && vendor/bin/phpunit) && (cd front && npx vitest run)"`. Le schéma de configuration, le parseur des hooks et `gate-checker` restent inchangés ; en contrepartie, une gate exécute les outils de tous les sous-projets, ce qui est voulu pour un ticket qui touche un contrat.
7. **Blocs Gutenberg** : bloc `typescript` dont le `path` est le dossier des sources JavaScript, pour que le PHP du même dossier reste dans le bloc `wordpress`.

## Conséquences

- Un ticket mixte est de taille L au triage (règle existante) et lit une section de plus par rôle concerné (environ 10 lignes).
- Le case `rules-angular-reviewer-quality` vérifie le chargement des critères front ; le comportement mixte relève des cases du ticket `mixed-modern-feature-01`.
- Si les gates par sous-projet deviennent trop lentes, une clé `tooling` par bloc `stacks[]` pourra être ajoutée sans casser ce format (nouvel ADR).
