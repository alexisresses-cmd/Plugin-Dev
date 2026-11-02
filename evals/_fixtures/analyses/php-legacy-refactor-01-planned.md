---
ticket: "#12"
title: Centraliser le calcul des frais de port
date: 2026-11-02
task_type: refactor
size: M
profiles: [php-native]
security_audit: false
status: planned
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

# Plan d'implémentation

**Approuvé le** : 2026-11-02 — **Branche** : fix/12-centraliser-frais-de-port — **PR draft** : (aucune)

## Tâches
[ ] T1 — Tests de caractérisation du calcul de port (seuils 49,99 / 50,00 / 50,01 pour chaque écran, y compris l'écart du back-office)
    Fichiers : tests/test_shipping.php — créer — Simple
[ ] T2 — Extraire `shop_shipping_fee($total, $free_from_strictly_above = false)` dans includes/functions.php, sans l'utiliser
    Fichiers : includes/functions.php — modifier — Simple
[ ] T3 — Utiliser la fonction dans cart.php et checkout.php
    Fichiers : cart.php, checkout.php — modifier — Simple
[ ] T4 — Utiliser la fonction dans admin/order_edit.php en préservant le seuil strict
    Fichiers : admin/order_edit.php — modifier — Simple

## Hors périmètre
- Corriger l'écart `>` / `>=` du back-office (ticket séparé proposé).

## Mode recommandé
dev-cycle — refactor M, sans risque sécurité

