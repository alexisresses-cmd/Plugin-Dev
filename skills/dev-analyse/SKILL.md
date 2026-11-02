---
name: dev-analyse
description: >
  Analyse d'un ticket avant tout développement : triage (type de tâche, besoin d'audit sécurité),
  puis agents spécialisés en parallèle (métier, code, architecture, sécurité) et synthèse.
  Accepte une URL GitHub Issues, une URL Trello ou du texte. Produit analysis/YYYYMMDD-{slug}.md,
  point d'entrée de /devflow:dev-plan. Déclencher en début de ticket.
argument-hint: "<url-ticket | numéro | texte>"
---

# dev-analyse — Analyse multi-agents d'un ticket

Tu es l'**orchestrateur** de l'analyse. Tu fais le triage, tu lances les agents, tu consolides. Tu n'analyses pas le code toi-même : les agents le font dans leur propre contexte.

> **Phase lecture seule.** Aucun fichier n'est modifié, sauf le fichier d'analyse final.

## Étape 0 — Récupération du ticket

Argument : `$ARGUMENTS`

| Format | Action |
|---|---|
| URL GitHub Issues `https://github.com/{owner}/{repo}/issues/{id}` | `gh issue view {id} --repo {owner}/{repo}` |
| Numéro seul + `ISSUE_TRACKER: github` dans `CLAUDE.md` | `gh issue view {id}` |
| URL Trello | WebFetch, extraire titre et description |
| Texte | tel quel ; extraire un identifiant s'il y en a un (`#42`, `TICKET-123`) |
| Rien | demande le ticket et arrête-toi |

## Étape 1 — Triage

Détermine, avec une phrase de justification chacun :
- **`task_type`** : `feature` (nouvelle capacité, user story), `bugfix` (comportement incorrect), `refactor` (dette, restructuration sans changement fonctionnel).
- **`security_audit`** : `true` si le ticket touche une entrée utilisateur, l'authentification ou les droits, un upload, une API exposée, des données personnelles, ou en cas de doute ; sinon `false`.

## Étape 2 — Agents en parallèle

Lance **dans un seul message** (outil Agent, appels parallèles) :

| Agent (`subagent_type`) | Condition |
|---|---|
| `devflow:business-analyst` | toujours |
| `devflow:code-mapper` | toujours |
| `devflow:architect` | toujours |
| `devflow:security-analyst` | si `security_audit: true` |

Message à chaque agent : le texte complet du ticket, `task_type`, et la consigne « Applique ta procédure et réponds au format demandé ». Ne leur transmets pas `CLAUDE.md` : ils le lisent eux-mêmes.

Si un agent échoue ou ne respecte pas son format, note-le dans la synthèse et continue.

## Étape 3 — Fichier d'analyse

Crée `analysis/` si besoin. Nom : `analysis/{YYYYMMDD}-{slug}.md` (slug en kebab-case, 5 mots maximum).

```markdown
---
ticket: {URL ou identifiant}
title: {titre}
date: {YYYY-MM-DD}
task_type: {feature|bugfix|refactor}
security_audit: {true|false}
status: analysed
---

# Analyse — {titre}

## Ticket
{texte du ticket}

## Vision métier
{sortie de business-analyst}

## Vision code
{sortie de code-mapper}

## Vision architecture
{sortie de architect}

## Vision sécurité
{sortie de security-analyst, ou « Audit non requis : {justification du triage} »}

## Synthèse
**Reformulation** : …
**Approche recommandée** : …
**Fichiers clés** : …
**Risques prioritaires** : top 3, tous agents confondus, du plus critique au moins critique
**Questions bloquantes** : … ou « Aucune »
**Feu vert** : ✅ | ⚠️ | ❌

<!-- PLAN — complété par /devflow:dev-plan -->
```

Copie les sorties des agents telles quelles : ne les reformule pas.

## Étape 4 — Restitution

N'affiche **pas** les rapports complets dans la conversation (ils sont dans le fichier). Affiche :

```
📋 ANALYSE — {titre} | {task_type} | audit sécu : {oui/non}

Reformulation : …
Approche recommandée : …
Fichiers clés : …
Risques prioritaires : 1. … 2. … 3. …
Questions bloquantes : …
Feu vert : ✅ / ⚠️ / ❌

📄 analysis/{fichier}.md
```

Puis :
- ✅ ou ⚠️ → « Lance `/devflow:dev-plan` pour planifier. »
- ❌ → « Résous les questions bloquantes avant `/devflow:dev-plan`. »

Pour un `bugfix`, l'approche recommandée est toujours le correctif minimal. Si un agent propose une refonte, mentionne-la comme dette à mettre au backlog.

Le feu vert est **ton** jugement d'orchestrateur, pas un vote des agents. Fusionne les risques qu'ils signalent en double.
