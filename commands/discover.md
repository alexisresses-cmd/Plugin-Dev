---
description: Découvre un projet existant (legacy) avec trois agents en parallèle et produit .devflow/project-map.md et un brouillon de .devflow/conventions.md, validé par l'utilisateur avant écriture
argument-hint: "[--yes]"
---

# /devflow:discover — Découverte d'un projet existant

Arguments : `$ARGUMENTS`
- `--yes` : n'affiche aucune question et écrit directement. Ne remplace jamais un `.devflow/conventions.md` déjà rempli : le brouillon va alors dans `.devflow/conventions.draft.md`.

Tu es l'**orchestrateur** : les agents explorent le code dans leur propre contexte, tu assembles leurs sorties **sans les reformuler**. Tu ne lis pas le code toi-même.

## Étape 0 — Préalables

1. Lis `.devflow/config.yml` (puis `.devflow/config.local.yml`, qui l'emporte). Absent : demande de lancer `/devflow:init` et arrête-toi.
2. Aucun bloc `stacks[]` en mode `legacy` : signale que la commande vise les projets legacy, puis continue.
3. `.devflow/conventions.md` est **rempli** s'il contient au moins une ligne de liste (`- `) sous un titre `## `. Note-le pour l'étape 3.

## Étape 1 — Agents en parallèle

Lance **dans un seul message** (outil Agent, trois appels parallèles) : `devflow:cartographer`, `devflow:convention-detector`, `devflow:risk-mapper`.

Message à chaque agent : les blocs `stacks[]` de la configuration (`path`, `profile`, `mode`) et la consigne « Pas de ticket. Applique ta procédure, échantillonne, et réponds au format demandé ».

Un agent qui échoue ou ne respecte pas son format : remplace ses sections par `_Non produit : {raison}_` et continue.

## Étape 2 — Assemblage

- **Carte** : copie `${CLAUDE_PLUGIN_ROOT}/templates/project-map.md` ; renseigne la date et le commit (`git rev-parse --short HEAD`, sinon `—`) ; place sous chaque titre le contenu de la section de même titre de `cartographer` ou de `risk-mapper` ; dans `## Couverture de l'analyse`, une ligne par agent reprenant sa section `## Échantillonnage`. Retire le commentaire d'assemblage.
- **Brouillon de conventions** : copie `${CLAUDE_PLUGIN_ROOT}/templates/conventions.md` et place sous chaque titre la section de même titre de `convention-detector`.

## Étape 3 — Validation (sans `--yes`)

Affiche un résumé de la carte (modules, points d'entrée, zones de risque élevé) et le brouillon de conventions **en entier**. Puis, avec **AskUserQuestion** (4 questions au plus par appel) :
1. une question par point de `## Incohérences observées` (les plus structurants d'abord) : quel style retenir, avec les deux styles observés en options. Le style retenu devient une règle de la section concernée ; un point non tranché reste dans `## Incohérences observées` ;
2. le brouillon : « Valider », « Corriger » (l'utilisateur décrit ses corrections ; applique-les puis ré-affiche le brouillon), « Ne pas écrire les conventions » (seule la carte est écrite) ;
3. si `conventions.md` est déjà rempli : « Fusionner » (ajoute les règles absentes, liste les contradictions sans rien remplacer), « Écrire dans `conventions.draft.md` », « Remplacer ».

Rien n'est écrit avant ces réponses.

## Étape 4 — Écriture

Crée `.devflow/` si besoin.
- `.devflow/project-map.md` : écrit (remplace la carte précédente, régénérée par nature).
- Conventions :

| Situation | `--yes` | Sans `--yes` |
|---|---|---|
| `conventions.md` absent ou vide (modèle seul) | écrit `conventions.md` | écrit `conventions.md` après validation |
| `conventions.md` rempli | écrit `conventions.draft.md` | selon la réponse (fusion, brouillon, remplacement) |

## Bilan

```
✅ Projet découvert
  Carte : .devflow/project-map.md — {n} modules, {n} points d'entrée, zones à risque élevé : {liste}
  Conventions : {fichier écrit} — {n} règles, {n} incohérences {tranchées | à trancher}
  Échantillonnage : {n} fichiers lus sur {total}

Suite : relis et commite `.devflow/` ; puis /devflow:dev-analyse <ticket>
```
