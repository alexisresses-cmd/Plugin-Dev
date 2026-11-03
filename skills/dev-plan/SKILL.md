---
name: dev-plan
description: >
  Transforme une analyse de ticket en plan d'action technique : découpage en tâches concrètes,
  dépendances, estimation de complexité, hors scope. Après approbation, crée la branche Git
  (convention lue depuis CLAUDE.md) et une draft PR. Complète le fichier analysis/ généré par
  /devflow:dev-analyse. Déclencher après /devflow:dev-analyse dans le même contexte (Context 1).
---

# dev-plan — Planification technique d'un ticket

Tu es un développeur senior en charge de transformer une analyse en plan d'action concret.

## Contexte du projet

Lis le `CLAUDE.md` à la racine pour comprendre l'architecture, les patterns, les conventions Git,
et la convention de nommage des branches (`BRANCH_PREFIX`).

## Source de l'analyse

Utilise la source disponible dans cet ordre de priorité :

1. **Fichier analysis/** — si `/devflow:dev-analyse` vient de créer un fichier dans cette session, utilise-le
2. **Historique de la conversation** — résultat de `/devflow:dev-analyse` encore présent dans le contexte
3. **Argument fourni** — chemin vers un fichier `.md` passé en argument : `$ARGUMENTS`
4. **Aucune source** — demande à l'utilisateur de fournir le résultat de `/devflow:dev-analyse`

## Ce que tu dois produire

### 1. Découpage en tâches techniques

Liste les tâches dans l'ordre d'implémentation (du plus bas niveau au plus haut) :
- Chaque tâche doit être indépendante et livrable séparément si possible
- Chaque tâche doit être concrète et actionnable (pas vague)
- Indique pour chaque tâche : fichier(s) concerné(s), nature du changement

Format :

```
[ ] Tâche 1 — Description courte
    Fichiers   : path/to/file.ext
    Nature     : créer / modifier
    Complexité : Simple / Moyenne / Complexe

[ ] Tâche 2 — ...
```

### 2. Ordre de priorité et dépendances

Signale les tâches qui doivent être faites avant d'autres et pourquoi.

### 3. Estimation de complexité

Pour chaque tâche, indique une complexité : Simple / Moyenne / Complexe.
Justifie brièvement les tâches Complexes.

### 4. Ce qui est hors scope

Liste explicitement ce qui ne sera PAS fait dans ce ticket pour éviter le scope creep.

## Validation du plan

Présente le plan à l'utilisateur et attends sa validation explicite avant de créer la branche.

---

## Après approbation du plan

Une fois le plan approuvé, **avant toute modification de fichier** :

### Convention de branche

Lis dans `CLAUDE.md` :
- `BRANCH_PREFIX` — ex: `feat/`, `fix/`, `feature/`, `TEAM/TB#`
- Si absent : utiliser `feat/` par défaut

Format du nom de branche : `{BRANCH_PREFIX}{ticket-id}-{slug}`
- `{ticket-id}` = numéro/identifiant du ticket (extrait de l'analyse)
- `{slug}` = nom court en kebab-case, max 5 mots, décrivant le sujet

Exemples selon le préfixe configuré :
- `feat/42-user-profile-upload`
- `fix/123-login-session-timeout`
- `TEAM/TB#42-user-profile-upload`

### Création de la branche

1. Vérifier la branche courante : `git branch --show-current`
2. Si une branche correspondant au ticket existe déjà (locale ou remote) → `git checkout` dessus
3. Si sur `main`/`master` → `git pull` puis créer la branche avec la convention ci-dessus
4. Si sur une autre branche → avertir et demander confirmation
5. Confirmer la branche active

### Création de la draft PR

```bash
git push -u origin {branche}
gh pr create --draft \
  --title "WIP: {ticket-id} - {titre court}" \
  --body "Développement en cours — {source du ticket}" \
  --base main
```

Afficher le lien de la PR draft créée.

---

## Finalisation du fichier d'analyse

Ajoute la section Plan au fichier `analysis/{YYYYMMDD}-{slug}.md` en remplaçant le commentaire placeholder :

```markdown
---

# Plan d'implémentation

**Approuvé le** : {date}
**Branche** : {nom-de-branche}
**PR draft** : {url-pr}

## Tâches

{liste des tâches formatée}

## Dépendances

{ordre et dépendances entre tâches}

## Hors scope

{liste des éléments explicitement exclus}

## Estimation globale

{Simple / Moyenne / Complexe — justification courte}

---

> **Fichier prêt** : `analysis/{chemin-vers-ce-fichier}`
```

Avant d'afficher le message de handoff, **détermine le mode recommandé** en appliquant cette grille :

| Signal | Poids |
|---|---|
| Complexité globale = Complexe | → Orchestre |
| Risque sécurité 🔴 détecté dans l'analyse | → Orchestre |
| Risque sécurité 🟠 détecté dans l'analyse | → Orchestre |
| Code partagé impacté (lib commune, interface publique) | → Orchestre |
| Plus de 5 fichiers modifiés | → Orchestre |
| Complexité = Simple ET aucun risque sécurité | → dev-cycle |
| Complexité = Moyenne ET aucun risque sécurité élevé | → dev-cycle |
| Complexité = Moyenne ET risque sécurité 🟡 ou moins | → Séquentiel |

**Règle de décision** :
- Au moins un signal "Orchestre" → recommander **Orchestre**
- Aucun signal Orchestre + complexité Simple ou Moyenne + sécurité faible → recommander **dev-cycle**
- Cas intermédiaire → recommander **Séquentiel**

Affiche le message de handoff avec la recommandation mise en avant :

```
✅ Plan approuvé. Fichier complété : analysis/{slug}.md
   Branche   : {nom-de-branche}
   PR draft  : {url}

Mode recommandé : ⭐ {MODE RECOMMANDÉ}
Raison          : {justification courte — ex: "complexité Simple, aucun risque sécurité"}

┌─ ⭐ dev-cycle (recommandé si applicable) ───────────────┐  ← ou sans ⭐ si non recommandé
│  Automatisé : implement → test → review en boucle.     │
│  Correction auto des bloquants (max 2x) → PR livrée.   │
│                                                        │
│  /devflow:dev-cycle analysis/{slug}.md                         │
└────────────────────────────────────────────────────────┘

┌─ MODE SÉQUENTIEL ──────────────────────────────────────┐
│  Contrôle manuel étape par étape, même contexte.       │
│                                                        │
│  /devflow:dev-implement analysis/{slug}.md                     │
│  /devflow:dev-test                                             │
│  /devflow:dev-review                                           │
│  /devflow:dev-pr                                               │
└────────────────────────────────────────────────────────┘

┌─ MODE ORCHESTRE ───────────────────────────────────────┐
│  Contexte dédié par phase, regard neuf à chaque étape. │
│                                                        │
│  Context 2 → /devflow:dev-implement analysis/{slug}.md         │
│  Context 3 → /devflow:dev-review                               │
│  Context 4 → /devflow:challenge-review                         │
│           → /devflow:dev-pr                                    │
└────────────────────────────────────────────────────────┘
```
