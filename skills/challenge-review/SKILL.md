---
name: challenge-review
description: >
  Challenge chaque point d'une review (sortie de /devflow:dev-review, commentaires d'une PR
  GitHub, ou texte collé) via l'agent review-challenger, et restitue un tableau de verdicts
  (valide / discutable / invalide) avec la sévérité réelle et ce que la review a manqué.
  Trigger : /devflow:challenge-review, "challenge la review", "audit les retours", "stress-teste la review".
argument-hint: "[pr-url | pr-number | texte]"
---

# challenge-review — Challenge d'une review

## Étape 1 — Récupérer les points de review

| Source | Action |
|---|---|
| Findings de `/devflow:dev-review` dans la conversation | reprends le JSON tel quel |
| PR GitHub (URL ou numéro dans `$ARGUMENTS`) | `gh pr view {n} --comments` et `gh api repos/{owner}/{repo}/pulls/{n}/comments --paginate` ; base : `gh pr view {n} --json baseRefName` |
| Texte collé | tel quel |

Si aucune source n'est disponible, demande-la.

## Étape 2 — Agent

Lance `devflow:review-challenger` avec la liste des points (copiée telle quelle) et la branche de base.

## Étape 3 — Restitution

À partir du JSON renvoyé :

| # | Point de review | Verdict | Sévérité réelle | Justification technique | Action |
|---|---|---|---|---|---|
| B1 | … | ✅ Valide / ⚠️ Discutable / ❌ Invalide | 🔴 Bloquant / 🟠 À corriger / 🟡 Note / ⚫ Non pertinent | … | Corriger / Discuter / Ignorer |

Correspondance : `blocking` → 🔴, `should-fix` → 🟠, `note` → 🟡, `irrelevant` → ⚫.

```markdown
## Résumé exécutif
- Points valides et bloquants : X
- Points discutables : X (à arbitrer)
- Points invalides : X
- Ce que la review a manqué : {missed, ou « rien »}
- Verdict global : {summary}
```

Ne modifie aucun fichier : pour appliquer les corrections, utilise `/devflow:dev-review` (correction automatique) ou corrige à la main, puis `/devflow:dev-commit`.
