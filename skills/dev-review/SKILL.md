---
name: dev-review
description: >
  Revue du diff de la branche par des agents en parallèle (qualité, bugs, sécurité selon le
  triage), challenge des findings, puis gate G2 avec correction automatique des bloquants
  (2 tentatives max). Produit un verdict go / go_with_reserves / no_go. Déclencher après
  /devflow:dev-implement et /devflow:dev-test, ou depuis /devflow:dev-cycle.
argument-hint: "[analysis/YYYYMMDD-slug.md]"
---

# dev-review — Revue multi-agents + gate G2

Tu es l'**orchestrateur** de la revue. Les agents lisent le diff eux-mêmes : ne le charge pas dans ta conversation.

## Étape 0 — Contexte

- Base : `main` si elle existe, sinon `master`.
- Fichier d'analyse : `$ARGUMENTS`, sinon celui de la session, sinon le plus récent. Lis seulement son en-tête (`task_type`, `security_audit`).
- `git diff <base>...HEAD --stat`. Diff vide → signale-le et arrête-toi.
- Compteur de corrections : `corrections = 0`.

## Étape 1 — Reviewers en parallèle

Lance **dans un seul message** :

| Agent | Condition |
|---|---|
| `devflow:reviewer-quality` | toujours |
| `devflow:reviewer-bugs` | toujours |
| `devflow:reviewer-security` | sauf si `security_audit: false` **et** que le diff ne touche ni contrôleur, formulaire, template, requête SQL, upload, ni configuration de sécurité |

Message : « Base : {base}. Fichier d'analyse : {chemin}. Applique ta procédure et réponds au format demandé. »

Fusionne les tableaux JSON. Dédoublonne les findings qui visent le même problème au même endroit (garde la sévérité la plus haute et les deux ids).

## Étape 2 — Challenge

Lance `devflow:review-challenger` avec les findings fusionnés (JSON) et la base.

Findings **retenus** : verdict `valid` ou `debatable`, avec `real_severity` comme sévérité, plus les findings `missed`. Les findings `invalid` sont écartés, mais listés dans le rapport.

## Étape 3 — Gate G2

Lance `devflow:gate-checker` avec `gate: G2`, la base, le fichier d'analyse et les findings retenus.

- `PASS` → étape 5.
- `FAIL` et `corrections < 2` → étape 4.
- `FAIL` et `corrections = 2` → étape 5 avec le statut HALT.

## Étape 4 — Correction automatique

`corrections += 1`. Corrige **uniquement** les findings retenus `blocking` et les critères G2 en échec (`reasons`) : lis le code, applique la correction, sans aucun nettoyage opportuniste. Commite via `devflow:dev-commit --auto -- correction review`. Puis reprends à l'étape 1 (nouvelle revue complète).

## Étape 5 — Rapport

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
{✅|⚠️|❌} REVIEW — verdict : {go|go_with_reserves|no_go}
Gate G2 : {PASS|HALT} {après N correction(s)}

🔴 Bloquants : {liste ou « aucun »}
🟠 À corriger : [id] fichier:ligne — issue
🟡 Notes : …
🚫 Écartés par le challenger : [id] — justification
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Verdict : `go` (aucun bloquant ni à-corriger), `go_with_reserves` (aucun bloquant), `no_go` (bloquants restants).

- PASS → « Prochaine étape : `/devflow:dev-pr` ».
- HALT → « 🛑 Correction manuelle requise » et liste des points restants.

Garde en mémoire de conversation les findings retenus : `/devflow:dev-pr` les reprend dans la description de la PR.
