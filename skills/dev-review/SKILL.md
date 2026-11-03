---
name: dev-review
description: >
  Revue de code approfondie via 3 sous-agents spécialisés en parallèle avec contrôle
  du modèle et de l'effort : qualité (Sonnet/medium), bugs (Sonnet/medium), sécurité
  (Opus/high). Gate G2 avec corrections automatiques max 2×. Produit un verdict
  go/go_with_reserves/no_go et un signal clair pour la transition vers Context 4.
  Déclencher dans Context 3 après /devflow:dev-implement et /devflow:dev-test.
---

# dev-review

Utilise l'outil **Workflow** pour lancer le workflow nommé `devflow:dev-review-run`.

Aucun argument requis — le workflow récupère lui-même le diff git et le `CLAUDE.md`.

---

## Modèles et effort par agent

| Agent | Modèle | Effort | Raison |
|---|---|---|---|
| Récupération du contexte (diff, CLAUDE.md) | Sonnet | low | Tâche mécanique |
| Review — qualité code | Sonnet | medium | Analyse de patterns |
| Review — bugs | Sonnet | medium | Analyse de logique |
| Review — sécurité | **Opus** | **high** | Détection de failles non évidentes |
| Agent correctif (Gate G2) | Sonnet | low | Corrections ciblées |

---

## Gate G2

Après la review, évalue automatiquement si des bloquants existent :

```
findings_blocking = []  →  ✅ PASS
findings_blocking ≠ []  →  agent correctif → re-review (max 2×)
```

Signal final :
- `✅ PRÊT POUR CONTEXT 4 → /devflow:challenge-review`
- `🛑 HALT — correction manuelle requise`
