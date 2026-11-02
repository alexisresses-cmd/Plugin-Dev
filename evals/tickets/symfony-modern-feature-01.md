---
id: symfony-modern-feature-01
project: fixture:symfony-api
profile: symfony
mode: modern
task_type: feature
size: M
milestone: M1
---
## Projet témoin
API Symfony 7 / PHP 8.3, Doctrine, PHPUnit + WebTestCase, PHPStan niveau 8. Entités `Product`, `Category`. Endpoints REST `GET/POST /api/products`. Sécurité : JWT, rôles `ROLE_USER`, `ROLE_ADMIN`.

## Ticket
#42 — En tant qu'administrateur, je veux pouvoir archiver un produit pour qu'il n'apparaisse plus dans le catalogue public sans perdre son historique de commandes.
- Nouveau endpoint `POST /api/products/{id}/archive`, réservé aux administrateurs.
- Un produit archivé est exclu de `GET /api/products`, mais reste accessible via `GET /api/products/{id}` pour les administrateurs.

## Critères attendus
- [ ] Migration Doctrine générée (champ `archivedAt` nullable), réversible.
- [ ] Contrôle d'accès par Voter ou `#[IsGranted]` (pas de vérification dans le contrôleur à la main).
- [ ] Contrôleur fin, logique dans un service.
- [ ] Filtre appliqué au niveau du Repository / QueryBuilder (pas en PHP après chargement).
- [ ] Tests WebTestCase : 403 pour un utilisateur, 200 pour un admin, produit absent de la liste.
- [ ] `reviewer-security` ne remonte aucun bloquant ; PHPStan vert.
