---
name: dev-plan
description: >
  Transforme une analyse de ticket en plan validé : planners en parallèle (développeur, CTO),
  puis challenger du plan, synthèse et validation par l'utilisateur. Après validation, crée la
  branche et la draft PR, complète le fichier analysis/ et recommande un mode d'exécution.
  Déclencher après /devflow:dev-analyse.
argument-hint: "[analysis/YYYYMMDD-slug.md]"
---

# dev-plan — Planification d'un ticket

Tu es l'**orchestrateur** de la planification. Les agents proposent et challengent ; toi, tu fais la synthèse, tu obtiens la validation et tu agis sur git et GitHub.

## Étape 0 — Fichier d'analyse

Dans l'ordre : `$ARGUMENTS` ; le fichier créé par `/devflow:dev-analyse` dans cette session ; le fichier `analysis/*.md` le plus récent dont le `status` vaut `analysed`. Sinon, demande-le.

Si la synthèse indique **Feu vert : ❌**, rappelle les questions bloquantes et arrête-toi.

## Étape 1 — Planners en parallèle

Lance **dans un seul message** :
- `devflow:planner-dev`
- `devflow:planner-cto`

Message : « Fichier d'analyse : {chemin}. Applique ta procédure et réponds au format demandé. »

## Étape 2 — Challenge

Lance `devflow:plan-challenger` avec le chemin du fichier d'analyse et les deux sorties précédentes, copiées telles quelles.

## Étape 3 — Synthèse et validation

Construis le plan final :
- tâches de `planner-dev`, ajustées selon les arbitrages de `planner-cto` et les objections 🔴 / 🟠 du challenger que tu juges fondées ;
- pour chaque objection non retenue, une justification d'une ligne.

Présente :

```
## Plan — {titre}
Tâches :
[ ] T1 — … (fichiers, nature, complexité)
Dépendances : …
Hors périmètre : …
Estimation : Simple | Moyenne | Complexe
Objections traitées : … | Objections écartées : … (pourquoi)
Mode recommandé : {mode} — {raison}
```

**Attends la validation explicite de l'utilisateur.** Applique ses corrections et représente le plan si nécessaire. Aucune action git avant sa validation.

## Étape 4 — Branche et draft PR (après validation)

Convention lue dans `CLAUDE.md` : `BRANCH_PREFIX` (défaut `feat/`). Nom : `{BRANCH_PREFIX}{ticket-id}-{slug}` (slug en kebab-case, 5 mots maximum).

1. `git branch --show-current`.
2. Si une branche du ticket existe déjà (locale ou distante) : `git checkout` dessus.
3. Si tu es sur `main` / `master` : `git pull`, puis crée la branche.
4. Si tu es sur une autre branche : avertis l'utilisateur et demande confirmation.
5. Draft PR :
   ```bash
   git push -u origin {branche}
   gh pr create --draft --title "WIP: {ticket-id} - {titre court}" --body "Développement en cours — {source du ticket}" --base {main|master}
   ```

## Étape 5 — Fichier d'analyse

Passe `status` à `planned` dans l'en-tête, puis remplace le commentaire `<!-- PLAN … -->` par :

```markdown
# Plan d'implémentation

**Approuvé le** : {date} — **Branche** : {branche} — **PR draft** : {url}

## Tâches
{tâches validées}

## Dépendances
## Hors périmètre
## Estimation globale
## Objections du challenger
{tableau du challenger, plus la décision pour chaque objection}

## Mode recommandé
{mode} — {raison}
```

## Étape 6 — Passage de relais

```
✅ Plan approuvé — analysis/{fichier}.md
   Branche : {branche}   PR draft : {url}

Mode recommandé : ⭐ {mode}

• Automatisé           /devflow:dev-cycle analysis/{fichier}.md
• Avec validations     /devflow:dev-cycle analysis/{fichier}.md --checkpoints
• Séquentiel           /devflow:dev-implement analysis/{fichier}.md → /devflow:dev-test → /devflow:dev-review → /devflow:dev-pr
```
