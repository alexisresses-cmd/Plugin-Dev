---
ticket: "#57"
title: Total de commande faux de 1 centime
date: 2026-11-02
task_type: bugfix
size: M
profiles: [symfony]
security_audit: false
status: analysed
---

# Analyse — Total de commande faux de 1 centime

## Synthèse
**Approche recommandée** : correctif minimal dans `OrderTotalCalculator::total` (arrondi de la remise au lieu de `floor`), précédé d'un test de reproduction.
**Feu vert** : ✅
