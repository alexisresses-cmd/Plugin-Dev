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

## Étape 0 — Configuration et ticket

Lis `.devflow/config.yml` (puis `.devflow/config.local.yml`, qui l'emporte). Absent : demande de lancer `/devflow:init` et arrête-toi.

Argument : `$ARGUMENTS`

| Format | Action |
|---|---|
| URL GitHub Issues `https://github.com/{owner}/{repo}/issues/{id}` | `gh issue view {id} --repo {owner}/{repo}` |
| Numéro seul + `issue_tracker: github` | `gh issue view {id}` |
| URL Trello | WebFetch, extraire titre et description |
| Texte | tel quel ; extraire un identifiant s'il y en a un (`#42`, `TICKET-123`) |
| Rien | demande le ticket et arrête-toi |

## Étape 1 — Triage

Détermine, avec une phrase de justification chacun. Pour repérer les fichiers concernés, utilise seulement Glob et Grep **en mode liste de fichiers** : ne lis pas leur contenu (le diagnostic revient aux agents).
- **`task_type`** : `feature` (nouvelle capacité, user story), `bugfix` (comportement incorrect), `refactor` (dette, restructuration sans changement fonctionnel).
- **`security_audit`** : `true` si le ticket touche une entrée utilisateur, l'authentification ou les droits, un upload, une API exposée, des données personnelles, ou en cas de doute ; sinon `false`.
- **`size`** :
  - `S` : **toutes** ces conditions : 1 ou 2 fichiers, aucun changement de schéma ni d'API, `security_audit: false`, et la modification attendue est évidente sans investigation (ex. libellé, faute de frappe, constante). Un `bugfix` décrit par un **symptôme** (comportement observé, sans la correction à appliquer) n'est jamais S : il vaut M au minimum ;
  - `L` : plus de 8 fichiers, plusieurs profils ou sous-projets, changement de contrat d'API ou de schéma partagé, ou refactoring de grande ampleur ;
  - `M` : sinon.
- **`profiles`** : profils des `stacks[]` de la config dont les `path` contiennent les fichiers repérés.

## Étape 2 — Agents en parallèle

Lance **dans un seul message** (outil Agent, appels parallèles) :

| Agent (`subagent_type`) | S | M | L |
|---|---|---|---|
| `devflow:code-mapper` | ✅ | ✅ | ✅ |
| `devflow:business-analyst` | — | ✅ | ✅ |
| `devflow:architect` | — | ✅ | ✅ |
| `devflow:security-analyst` | si `security_audit` | si `security_audit` | si `security_audit` |

Message à chaque agent : le texte complet du ticket, `task_type`, `size`, et la consigne « Applique ta procédure et réponds au format demandé ». Ils lisent eux-mêmes la configuration et les règles.

Si un agent échoue ou ne respecte pas son format, note-le dans la synthèse et continue. Si la cartographie contredit la taille estimée (ex. un ticket S qui touche 5 fichiers), corrige `size` et, si elle passe à M ou L, lance les agents manquants.

## Étape 3 — Fichier d'analyse

Crée `analysis/` si besoin. Nom : `analysis/{YYYYMMDD}-{slug}.md` (slug en kebab-case, 5 mots maximum).

```markdown
---
ticket: {URL ou identifiant}
title: {titre}
date: {YYYY-MM-DD}
task_type: {feature|bugfix|refactor}
size: {S|M|L}
profiles: [{profil}, …]
security_audit: {true|false}
status: analysed
---

# Analyse — {titre}

## Ticket
{texte du ticket}

## Vision métier
{sortie de business-analyst, ou « Taille S : non requise »}

## Vision code
{sortie de code-mapper}

## Vision architecture
{sortie de architect, ou « Taille S : non requise »}

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
📋 ANALYSE — {titre} | {task_type} | taille {size} | {profils} | audit sécu : {oui/non}

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
