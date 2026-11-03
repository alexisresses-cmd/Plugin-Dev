---
name: dev-cycle
description: >
  Enchaîne tout le cycle après un plan approuvé : implémentation, gate G1, tests, revue
  multi-agents avec challenge et gate G2 (corrections automatiques, 2 tentatives max par gate),
  puis finalisation de la PR. Option --checkpoints pour valider chaque phase (ex-mode Orchestra).
  Déclencher après /devflow:dev-plan.
argument-hint: "<analysis/YYYYMMDD-slug.md> [--checkpoints]"
---

# dev-cycle — Cycle complet

Tu es le **chef d'orchestre**. Tu enchaînes des skills et des agents : le travail lourd (lecture du code, review, gates) se fait dans leurs contextes. Dans ta conversation, ne garde que leurs bilans.

Arguments : `$ARGUMENTS`
- chemin du fichier d'analyse (obligatoire : sinon, demande-le) ;
- `--checkpoints` : après chaque phase, présente le bilan et **attends la validation** de l'utilisateur avant de continuer (il peut corriger, relancer la phase ou arrêter).

## Phase 0 — Préconditions

- Lis l'en-tête et la section Plan du fichier d'analyse : `status` doit valoir `planned`, et la branche y est indiquée.
- `git branch --show-current` doit correspondre à cette branche. `git status --porcelain` doit être vide.
- En cas d'échec : 🛑 arrête-toi en expliquant pourquoi.

## Phase 1 — Implémentation

Invoque le skill `devflow:dev-implement` avec `{fichier} --orchestrator`. Garde son bilan JSON.

## Phase 2 — Gate G1 (max 2 corrections)

1. Lance `devflow:gate-checker` (`gate: G1`, base, fichier d'analyse).
2. `FAIL` → corrige uniquement les `reasons`, commite via `devflow:dev-commit --auto -- correction gate G1`, puis relance la gate. Au bout de 2 corrections encore en échec : **HALT** (rapport final, statut G1).

Si `CLAUDE.md` contient `SIMPLIFIER: true` : lance `devflow:dev-simplifier`, puis commite via `devflow:dev-commit --auto -- simplification` si des fichiers ont changé.

🔸 Checkpoint 1 (si `--checkpoints`).

## Phase 3 — Tests

Invoque le skill `devflow:dev-test` avec le fichier d'analyse. Si les tests échouent, corrige le code de production (pas les tests, sauf s'ils sont manifestement faux), commite via `devflow:dev-commit --auto -- correction tests`, puis relance les tests une fois.

🔸 Checkpoint 2 (si `--checkpoints`).

## Phase 4 — Revue et gate G2

Invoque le skill `devflow:dev-review` avec le fichier d'analyse : reviewers en parallèle, challenge, gate G2, 2 corrections maximum. Si le statut est HALT, rapport final avec le statut G2.

🔸 Checkpoint 3 (si `--checkpoints`) : présente les findings `should-fix` restants. L'utilisateur choisit de les corriger ou de les laisser dans la PR.

## Phase 5 — PR

Invoque le skill `devflow:dev-pr`. En mode sans checkpoints, ne pose pas de question : les findings restants vont dans « Points d'attention pour le reviewer ».

## Rapport final

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
{✅ dev-cycle terminé | 🛑 dev-cycle arrêté en {phase}}
Implémentation : {n} tâches, {n} commits
Gate G1        : {PASS|HALT} ({n} correction(s))
Tests          : {framework} — {n} cas — {pass|fail|not_run}
Revue          : {verdict} — G2 {PASS|HALT} ({n} correction(s))
PR             : {url} — {ready for review | draft}
Points restants : …
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
