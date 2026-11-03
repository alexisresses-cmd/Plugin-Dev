---
ticket: "#58"
title: Stock produit (API + administration)
date: 2026-11-02
task_type: feature
size: L
profiles: [symfony, angular]
security_audit: true
status: analysed
---

# Analyse — Stock produit (API + administration)

## Ticket
#58 — Ajouter un champ `stock` (entier ≥ 0) au produit : saisie dans le formulaire d'administration Angular, persistance et validation côté API, affichage « Rupture » quand `stock = 0`.

## Vision métier
### Reformulation
Un administrateur saisit le stock d'un produit ; la liste signale les produits en rupture.
### Critères d'acceptation
- [ ] Le formulaire d'administration (création et modification) propose un champ « Stock », entier ≥ 0.
- [ ] L'API refuse un stock négatif, décimal ou absent (422), même si le front est contourné.
- [ ] `GET /api/products` et `GET /api/products/{id}` renvoient `stock`.
- [ ] La liste affiche « Rupture » pour un produit dont le stock vaut 0.
- [ ] Les produits existants ont un stock de 0 après la migration.
### Questions ouvertes
- (mineure) Valeur par défaut des produits existants : 0 retenu (affichés « Rupture » jusqu'à saisie).

## Vision code
### Points d'entrée
- `api/src/Controller/Admin/ProductAdminController.php` — `POST`/`PUT /api/admin/products` avec `#[MapRequestPayload] ProductInput`.
- `api/src/Controller/ProductController.php` — lecture via `ProductOutput`.
- `front/src/app/products/admin/product-form.component.ts` — formulaire réactif typé.
- `front/src/app/products/product-list.component.ts` — liste.
### Contrat d'API
| Côté | Fichier | Rôle |
|---|---|---|
| PHP | api/src/Dto/ProductInput.php | entrée de `POST`/`PUT /api/admin/products` |
| PHP | api/src/Dto/ProductOutput.php | sortie de `GET /api/products[/{id}]` et des écritures |
| TS | front/src/app/products/product.ts | `Product` (miroir de ProductOutput), `ProductInput` (dérivé par `Omit`) |
### Fichiers impactés
| Fichier | Action | Profil | Raison |
|---|---|---|---|
| api/src/Entity/Product.php | modifier | symfony | colonne `stock` |
| api/migrations/ | créer | symfony | `ALTER TABLE product ADD stock INT DEFAULT 0 NOT NULL` |
| api/src/Dto/ProductInput.php | modifier | symfony | `stock` + `Assert\NotNull`, `Assert\PositiveOrZero` |
| api/src/Dto/ProductOutput.php | modifier | symfony | `stock` |
| api/src/Service/ProductWriter.php | modifier | symfony | report de `stock` |
| api/tests/Controller/Admin/ProductAdminControllerTest.php | modifier | symfony | 422 sur stock négatif, création avec stock |
| front/src/app/products/product.ts | modifier | angular | `stock: number` |
| front/src/app/products/admin/product-form.component.ts, .html | modifier | angular | champ `stock`, `Validators.min(0)`, entier |
| front/src/app/products/product-list.component.ts | modifier | angular | libellé « Rupture » |
| front/src/app/products/admin/product-form.component.spec.ts | modifier | angular | contrat envoyé, validation |
### Tests existants
API : `ProductAdminControllerTest` (401, 422 sur prix négatif). Front : `product-form.component.spec.ts` (contrat `ProductInput`).

## Vision architecture
### Recommandation
Changement de contrat d'API : DTO PHP et interface TS modifiés dans le même ticket, dans l'ordre contrat (DTO + interface) → serveur (entité, migration, writer) → client (formulaire, liste). La contrainte `Assert\PositiveOrZero` sur `ProductInput` fait foi ; `Validators.min(0)` côté Angular n'est qu'un confort de saisie. `ProductInput` TS reste dérivé de `Product` par `Omit`, ce qui propage le champ automatiquement.

## Vision sécurité
### Niveau global
🟡 — nouvelle donnée saisie par un administrateur, routes déjà protégées par `ROLE_ADMIN`.
### Risques
| Niveau | OWASP | Risque | Localisation | Mesure attendue |
|---|---|---|---|---|
| 🟡 | A04 | stock négatif accepté si seule la validation front existe | ProductInput | contrainte Symfony + test 422 |
| 🟡 | A04 | divergence de contrat PHP / TS (champ absent d'un côté) | Dto/, product.ts | mise à jour simultanée, test des deux côtés |

## Synthèse
**Reformulation** : champ `stock` saisi en administration, validé et persisté par l'API, « Rupture » à 0.
**Approche recommandée** : contrat des deux côtés d'abord, puis API (entité, migration, writer, WebTestCase), puis front (formulaire, liste, Vitest).
**Fichiers clés** : ProductInput.php, ProductOutput.php, product.ts, Product.php, migration, product-form.component, product-list.component.
**Risques prioritaires** : 1. validation serveur absente ; 2. divergence de contrat ; 3. migration sans valeur par défaut.
**Questions bloquantes** : Aucune
**Feu vert** : ✅

<!-- PLAN — complété par /devflow:dev-plan -->
