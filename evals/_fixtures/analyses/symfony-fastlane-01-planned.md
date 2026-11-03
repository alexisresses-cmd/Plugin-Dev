---
ticket: "#61"
title: Faute de frappe dans le message de validation du nom
date: 2026-11-02
task_type: bugfix
size: S
profiles: [symfony]
security_audit: false
status: planned
---

# Analyse — Faute de frappe dans le message de validation du nom

## Ticket
#61 — Faute de frappe dans le message de validation de `Product::$name` : « Le nom est obligatoir ».

## Vision code
- `src/Entity/Product.php` — contrainte `Assert\NotBlank(message: 'Le nom est obligatoir')`.

## Synthèse
**Approche recommandée** : corriger le libellé en « Le nom est obligatoire ».
**Feu vert** : ✅

# Plan d'implémentation

**Approuvé le** : 2026-11-02 — **Branche** : fix/61-message-nom-obligatoire — **PR draft** : (aucune)

## Tâches
[ ] T1 — Corriger le message de la contrainte NotBlank
    Fichiers : src/Entity/Product.php — modifier — Simple

## Mode recommandé
dev-cycle (voie rapide) — taille S
