---
name: dev-cycle
description: >
  Enchaîne tout le cycle après un plan approuvé : (G0 si refactor), implémentation, gate G1,
  tests, revue multi-agents avec challenge et gate G2 (corrections automatiques, 2 tentatives max
  par gate), puis finalisation de la PR. Voie rapide pour les tickets de taille S. Option
  --checkpoints pour valider chaque phase. Déclencher après /devflow:dev-plan.
argument-hint: "<analysis/YYYYMMDD-slug.md> [--checkpoints]"
---

# dev-cycle — Cycle complet

Tu es le **chef d'orchestre**. Tu enchaînes des skills et des agents : le travail lourd (lecture du code, review, gates) se fait dans leurs contextes. Dans ta conversation, ne garde que leurs bilans.

Arguments : `$ARGUMENTS`
- chemin du fichier d'analyse (obligatoire : sinon, demande-le) ;
- `--checkpoints` : active les validations entre phases, comme `pipeline.checkpoints: true`.

**Checkpoint** (si activé) : présente le bilan de la phase et **attends la validation** de l'utilisateur. Il peut corriger, relancer la phase ou arrêter.

## Phase 0 — Préconditions

- Configuration : `.devflow/config.yml` (+ `config.local.yml`). Absente : demande `/devflow:init` et arrête-toi.
- Fichier d'analyse : `status: planned`, branche indiquée dans la section Plan ; lis `task_type` et `size`.
- `git branch --show-current` doit correspondre à cette branche, et `git status --porcelain` doit être vide.
- En cas d'échec : 🛑 arrête-toi en expliquant pourquoi.
- **Voie rapide** si `size: S` et `pipeline.fast_lane: true` : exécute seulement les phases marquées ⚡ (implémentation, G1, PR). Une gate G1 en échec après 2 corrections fait sortir de la voie rapide : signale-le et propose le cycle complet.

## Phase 1 — Gate G0 (refactor uniquement)

Si `task_type: refactor` :
1. Lance `devflow:test-writer` avec `characterization:` et les fichiers de production du plan. Commite les tests via `devflow:dev-commit --auto -- tests de caractérisation`.
2. Lance `devflow:gate-checker` (`gate: G0`, fichiers de tests produits).
3. `FAIL` → une seule nouvelle tentative de `test-writer` avec les `reasons`, puis HALT (aucun refactoring sans filet).

🔸 Checkpoint 0.

## Phase 2 — Implémentation ⚡

Invoque le skill `devflow:dev-implement` avec `{fichier} --orchestrator`. Garde son bilan JSON.

## Phase 3 — Gate G1 ⚡ (2 corrections maximum)

1. Lance `devflow:gate-checker` (`gate: G1`, base, fichier d'analyse).
2. `FAIL` → corrige uniquement les `reasons`, commite via `devflow:dev-commit --auto -- correction gate G1`, puis relance la gate. Au bout de 2 corrections encore en échec : **HALT**.

Si `pipeline.simplifier: true` (hors voie rapide) : lance `devflow:dev-simplifier`, puis commite via `devflow:dev-commit --auto -- simplification` si des fichiers ont changé.

🔸 Checkpoint 1.

## Phase 4 — Tests

Invoque le skill `devflow:dev-test` avec le fichier d'analyse. Si les tests échouent, corrige le code de production (pas les tests, sauf s'ils sont manifestement faux), commite via `devflow:dev-commit --auto -- correction tests`, puis relance les tests une fois.

🔸 Checkpoint 2.

## Phase 5 — Revue et gate G2

Invoque le skill `devflow:dev-review` avec le fichier d'analyse : reviewers en parallèle, challenge, gate G2, 2 corrections maximum. Statut HALT : rapport final.

🔸 Checkpoint 3 : présente les findings `should-fix` restants. L'utilisateur choisit de les corriger ou de les laisser dans la PR.

## Phase 6 — PR ⚡

Invoque le skill `devflow:dev-pr`. Sans checkpoints, ne pose pas de question : les findings restants vont dans « Points d'attention pour le reviewer ».

## Rapport final

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
{✅ dev-cycle terminé | 🛑 dev-cycle arrêté en {phase}} — {cycle complet | voie rapide}
Gate G0        : {PASS|HALT|non applicable}
Implémentation : {n} tâches, {n} commits
Gate G1        : {PASS|HALT} ({n} correction(s))
Tests          : {framework} — {n} cas — {pass|fail|not_run|voie rapide}
Revue          : {verdict} — G2 {PASS|HALT} ({n} correction(s)) | voie rapide
PR             : {url} — {ready for review | draft}
Points restants : …
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
