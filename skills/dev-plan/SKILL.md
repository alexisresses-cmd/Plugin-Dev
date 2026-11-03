---
name: dev-plan
description: >
  Transforme une analyse de ticket en plan validé : brouillon du plan, challenge par un agent
  dédié, puis validation par l'utilisateur. Après validation, crée la
  branche et la draft PR, complète le fichier analysis/ et recommande un mode d'exécution.
  Déclencher après /devflow:dev-analyse.
argument-hint: "[analysis/YYYYMMDD-slug.md]"
---

# dev-plan — Planification d'un ticket

Tu es l'**orchestrateur** de la planification. Tu rédiges le brouillon, un agent le challenge, tu obtiens la validation et tu agis sur git et GitHub.

## Étape 0 — Fichier d'analyse

Dans l'ordre : `$ARGUMENTS` ; le fichier créé par `/devflow:dev-analyse` dans cette session ; le fichier `analysis/*.md` le plus récent dont le `status` vaut `analysed`. Sinon, demande-le.

Si la synthèse indique **Feu vert : ❌**, rappelle les questions bloquantes et arrête-toi.

## Étape 1 — Brouillon du plan

L'analyse contient déjà la cartographie du code et l'architecture recommandée. Rédige toi-même le brouillon, sans relire tout le code (vérifie seulement un point précis si l'analyse est ambiguë).

**Exception (tickets lourds)** : si la synthèse estime le ticket Complexe, ou s'il touche plus de 8 fichiers, délègue le brouillon à `devflow:planner-dev` et `devflow:planner-cto`, lancés **en parallèle**, puis fusionne leurs sorties. Cette règle sera remplacée par le triage S/M/L au M3.

Contenu du brouillon :
- **Tâches** dans l'ordre d'implémentation (données et migrations d'abord, contrôleur et vue ensuite), 8 au maximum, chacune concrète et committable seule si possible : fichiers, nature (créer / modifier / supprimer), complexité. Pour un `bugfix`, la première tâche est un test qui reproduit le bug. Pour un `refactor`, ce sont les tests de caractérisation.
- **Dépendances** entre tâches.
- **Pièges** d'implémentation, tirés des risques de l'analyse.
- **Hors périmètre**, précis.
- **Estimation globale** : Simple / Moyenne / Complexe.
- **Mode recommandé** :

  | Signal | Mode |
  |---|---|
  | Complexité Complexe, risque sécu 🔴/🟠, code partagé ou interface publique touchés, plus de 5 fichiers | `dev-cycle --checkpoints` |
  | Complexité Simple ou Moyenne, risque sécu 🟢 ou absent | `dev-cycle` |
  | Complexité Moyenne, risque sécu 🟡, besoin de valider chaque étape | séquentiel |

## Étape 2 — Challenge

Lance `devflow:plan-challenger` avec le chemin du fichier d'analyse et le brouillon, copié tel quel.

## Étape 3 — Synthèse et validation

Construis le plan final :
- le brouillon, ajusté selon les objections 🔴 / 🟠 du challenger que tu juges fondées ;
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
