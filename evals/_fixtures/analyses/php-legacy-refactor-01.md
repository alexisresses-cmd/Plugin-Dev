---
ticket: "#12"
title: Centraliser le calcul des frais de port
date: 2026-11-02
task_type: refactor
size: M
profiles: [php-native]
security_audit: false
status: analysed
---

# Analyse — Centraliser le calcul des frais de port

## Ticket
Centraliser le calcul des frais de port dans une seule fonction réutilisée par les trois écrans (`cart.php`, `checkout.php`, `admin/order_edit.php`).

## Vision code
### Fichiers impactés
| Fichier | Action | Raison |
|---|---|---|
| includes/functions.php | modifier | nouvelle fonction `shop_shipping_fee($total)` |
| cart.php | modifier | utilise les constantes `SHOP_FREE_SHIPPING_THRESHOLD` / `SHOP_SHIPPING_FEE`, seuil `>=` |
| checkout.php | modifier | valeurs en dur `50` / `4.90`, seuil `>=` |
| admin/order_edit.php | modifier | valeurs en dur `50` / `4.90`, seuil **`>`** |
### Tests existants
Aucun test automatisé ; aucun framework de test.

## Vision architecture
### Recommandation
Fonction `shop_shipping_fee($total)` dans `includes/functions.php` (convention `shop_` + `snake_case`), appelée par les trois écrans. **Écart de comportement** : `admin/order_edit.php` applique la gratuité au-delà de 50 € strictement (`>`), les deux autres à partir de 50 € (`>=`). Pour un total de 50,00 €, le back-office facture 4,90 € de port, le front 0 €.

## Synthèse
**Reformulation** : supprimer la triple duplication du calcul des frais de port, sans changement fonctionnel.
**Approche recommandée** : fonction unique ; l'écart `>` / `>=` est signalé et préservé (ticket séparé proposé), car le corriger serait un changement fonctionnel.
**Risques prioritaires** : 1. modifier le comportement du back-office à 50,00 € ; 2. aucun filet de tests ; 3. flottants (`4.90`).
**Questions bloquantes** : Aucune
**Feu vert** : ✅

<!-- PLAN — complété par /devflow:dev-plan -->
