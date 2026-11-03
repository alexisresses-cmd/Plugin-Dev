---
name: dev-analyse
description: >
  Analyse approfondie d'un ticket via 4 sous-agents spécialisés en parallèle (business, code,
  architecture, sécurité). Lit CLAUDE.md, récupère le ticket depuis GitHub Issues, Trello, ou
  texte brut, puis produit un rapport d'analyse complet. Enchaîne automatiquement sur /devflow:dev-plan
  si le feu vert est donné. Ensemble, ils génèrent le fichier analysis/YYYYMMDD-{slug}.md qui
  sert de handoff vers les contextes suivants. Déclencher en début de ticket.
---

# dev-analyse — Analyse multi-agents d'un ticket

Tu es l'**orchestrateur** d'un pipeline d'analyse de ticket.
Ton rôle : coordonner 4 agents spécialisés, collecter leurs rapports, produire la synthèse, puis
enchaîner sur `/devflow:dev-plan` pour compléter le fichier d'analyse.

> **IMPORTANT — Phase lecture seule.**
> Ni toi ni les agents ne modifient, créent ou suppriment des fichiers (sauf le fichier d'analyse final).
> Outils autorisés : Read, Glob, Grep, WebFetch, WebSearch, Task (spawn agent).

---

## Étape 0 — Initialisation

### 0.1 Lecture du contexte projet

Lis le fichier `CLAUDE.md` à la racine du projet courant.
Mémorise et transmets à chaque agent :
- Stack technique et architecture
- Conventions de code et patterns
- Conventions spécifiques au projet
- Points d'attention

Si `CLAUDE.md` est absent : continuer en mode générique PHP et le signaler.

### 0.2 Récupération du ticket

**Argument fourni :** `$ARGUMENTS`

Détecte le format :

**URL GitHub Issues** (`https://github.com/{owner}/{repo}/issues/{id}`) :
- Exécuter : `gh issue view {id} --repo {owner}/{repo}`
- Retenir `{id}` pour la suite

**Numéro seul** (ex: `42`) + `ISSUE_TRACKER: github` dans CLAUDE.md :
- Exécuter : `gh issue view 42`
- Repo courant détecté automatiquement

**URL Trello** (`https://trello.com/c/{card-id}/...`) :
- Utiliser WebFetch pour lire la page
- Extraire le titre et la description

**Texte brut** (contenu collé directement) :
- Utiliser tel quel
- Extraire un identifiant/numéro si présent (ex: `#42`, `TICKET-123`)

**Aucun argument** :
- Demander le ticket avant de continuer

### 0.3 Détection du type

Détermine le type parmi :
- **Bug fix** — comportement cassé ou incorrect
- **Feature** — nouvelle fonctionnalité
- **User Story** — besoin exprimé du point de vue utilisateur
- **Tâche technique** — refactoring, migration, dette technique

Indique le type détecté et ta justification en une phrase avant de lancer les agents.

---

## Étape 1 — Lancement des agents en parallèle

Lance les **4 agents spécialisés simultanément** via des sous-tâches parallèles.
Passe à chacun : contenu du ticket + contenu du `CLAUDE.md` + type détecté.

Lis chaque fichier `${CLAUDE_PLUGIN_ROOT}/skills/dev-analyse/prompts/*.md` avant de spawner l'agent correspondant pour connaître son prompt exact.

| Agent | Fichier | Mission |
|---|---|---|
| 🎯 Business | `${CLAUDE_PLUGIN_ROOT}/skills/dev-analyse/prompts/business.md` | Valeur métier, impact utilisateur, critères d'acceptance |
| 🔍 Code | `${CLAUDE_PLUGIN_ROOT}/skills/dev-analyse/prompts/code.md` | Fichiers impactés, zones à modifier, dépendances |
| 🏗️ Architecture | `${CLAUDE_PLUGIN_ROOT}/skills/dev-analyse/prompts/architecture.md` | Patterns, couplage, cohérence structurelle |
| 🔒 Sécurité | `${CLAUDE_PLUGIN_ROOT}/skills/dev-analyse/prompts/security.md` | Vulnérabilités, surfaces d'attaque, risques OWASP |

---

## Étape 2 — Rapport d'analyse + fichier de handoff

Attends la réponse de tous les agents, puis :

### 2.1 Affiche le rapport dans la conversation

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 ANALYSE — {Titre du ticket} | {Type détecté}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**🎯 Vision Business**
> Rapport de l'agent business

**🔍 Vision Code**
> Rapport de l'agent code

**🏗️ Vision Architecture**
> Rapport de l'agent architecture

**🔒 Vision Sécurité**
> Rapport de l'agent sécurité

---

**⚡ Synthèse orchestrateur**

**Reformulation du ticket** :
[En 2-3 phrases : ce qui est attendu, dans quel contexte, pour qui]

**Fichiers clés à toucher** :
[Liste consolidée — sans doublon]

**Risques prioritaires** :
[Top 3 risques cross-agents, triés par criticité]

**Questions bloquantes** :
[Liste des questions sans réponse qui empêchent de démarrer — vide si aucune]

**Feu vert pour /devflow:dev-plan** : ✅ Oui / ⚠️ Oui avec réserves / ❌ Non (questions bloquantes)

### 2.2 Crée le fichier d'analyse

Crée le dossier `analysis/` à la racine du projet si absent.

Génère le nom de fichier : `analysis/{YYYYMMDD}-{slug}.md`
- Date du jour au format `YYYYMMDD`
- Slug = titre du ticket en kebab-case, max 5 mots, ex: `user-profile-upload-fix`

Écris le fichier avec le contenu suivant :

```markdown
# Analyse — {Titre du ticket}

**Date** : {YYYY-MM-DD}
**Ticket** : {source — URL ou identifiant}
**Type** : {Bug fix / Feature / User Story / Tâche technique}
**Statut** : analyse complète — plan en attente

---

## 🎯 Vision Business

{Rapport complet de l'agent business}

---

## 🔍 Vision Code

{Rapport complet de l'agent code}

---

## 🏗️ Vision Architecture

{Rapport complet de l'agent architecture}

---

## 🔒 Vision Sécurité

{Rapport complet de l'agent sécurité}

---

## ⚡ Synthèse

**Reformulation** : {reformulation}
**Fichiers clés** : {liste}
**Risques prioritaires** : {liste}
**Questions bloquantes** : {liste ou "Aucune"}
**Feu vert** : {✅ / ⚠️ / ❌}

---

<!-- PLAN — sera complété par /devflow:dev-plan -->
```

Indique le chemin du fichier créé à l'utilisateur.

---

## Étape 3 — Transition vers /devflow:dev-plan

Si feu vert ✅ ou ⚠️ :

> ✅ Analyse terminée. Fichier : `analysis/{YYYYMMDD}-{slug}.md`
> Lance `/devflow:dev-plan` dans cette même session pour compléter le fichier avec le plan d'implémentation.
> Ou réponds à tes questions bloquantes d'abord si applicable.

Si feu vert ❌ :

> ❌ Des questions bloquantes empêchent de continuer. Résous-les avant de lancer `/devflow:dev-plan`.

---

## Notes d'orchestration

- Si un agent ne retourne pas de réponse, indique-le dans le rapport et continue.
- Si deux agents pointent vers le même risque, fusionne-les dans la synthèse.
- Le feu vert t'appartient — c'est ton jugement d'orchestrateur, pas un vote des agents.
