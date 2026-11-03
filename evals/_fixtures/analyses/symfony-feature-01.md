---
ticket: "#42"
title: Archivage d'un produit par un administrateur
date: 2026-11-02
task_type: feature
size: M
profiles: [symfony]
security_audit: true
status: analysed
---

# Analyse — Archivage d'un produit par un administrateur

## Ticket
#42 — En tant qu'administrateur, je veux pouvoir archiver un produit pour qu'il n'apparaisse plus dans le catalogue public sans perdre son historique de commandes.
- Nouveau endpoint POST /api/products/{id}/archive, réservé aux administrateurs.
- Un produit archivé est exclu de GET /api/products, mais reste accessible via GET /api/products/{id} pour les administrateurs.

## Vision métier
### Reformulation
Un administrateur retire un produit du catalogue sans le supprimer, pour conserver l'historique.
### Critères d'acceptation
- [ ] Seul un administrateur peut archiver (403 sinon).
- [ ] Un produit archivé n'apparaît plus dans la liste.
- [ ] Un administrateur voit encore la fiche d'un produit archivé ; un utilisateur standard reçoit 404.
- [ ] Archiver un produit déjà archivé ne provoque pas d'erreur.
### Questions ouvertes
- (mineure) Faut-il pouvoir désarchiver ? Hors périmètre du ticket.

## Vision code
### Points d'entrée
- `src/Controller/ProductController.php` — routes `/api/products`
- `src/Repository/ProductRepository.php` — `findCatalog()` alimente la liste
### Fichiers impactés
| Fichier | Action | Raison |
|---|---|---|
| src/Entity/Product.php | modifier | champ `archivedAt` |
| migrations/ | créer | colonne `archived_at` |
| src/Repository/ProductRepository.php | modifier | exclure les archivés de `findCatalog()` |
| src/Controller/ProductController.php | modifier | route `archive`, contrôle sur `show` |
| src/Security/Voter/ProductVoter.php | modifier | attributs `PRODUCT_ARCHIVE`, `PRODUCT_VIEW` |
| tests/Controller/ProductControllerTest.php | modifier | cas 403 / 200 / liste |
### Tests existants
`ProductControllerTest` ne couvre que le 401 sur la liste.

## Vision architecture
### Recommandation
Champ `archivedAt` (`?\DateTimeImmutable`) sur `Product`, avec une méthode `archive()` idempotente. Filtre dans `ProductRepository::findCatalog()`. Autorisation via `ProductVoter` (`#[IsGranted]`), comme `PRODUCT_CREATE`. Logique d'archivage dans un service `ProductArchiver`, pour garder le contrôleur fin.

## Vision sécurité
### Niveau global
🟠 — nouvelle action d'écriture et règle de visibilité sur `show`.
### Risques
| Niveau | OWASP | Risque | Localisation | Mesure attendue |
|---|---|---|---|---|
| 🟠 | A01 | archivage par un non-admin | ProductController | Voter `PRODUCT_ARCHIVE` |
| 🟠 | A01 | fiche d'un produit archivé visible par tous | ProductController::show | Voter `PRODUCT_VIEW` → 404 |

## Synthèse
**Reformulation** : archivage logique d'un produit, réservé aux administrateurs, exclu du catalogue public.
**Approche recommandée** : `archivedAt` + migration, filtre Repository, Voter, service `ProductArchiver`.
**Fichiers clés** : Product, migration, ProductRepository, ProductController, ProductVoter, tests.
**Risques prioritaires** : 1. contrôle d'accès sur `archive` ; 2. visibilité sur `show` ; 3. oubli du filtre sur d'autres requêtes de liste.
**Questions bloquantes** : Aucune
**Feu vert** : ✅

<!-- PLAN — complété par /devflow:dev-plan -->
