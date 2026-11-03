---
name: review-return
description: >
  Traite les retours d'une Pull Request laissés par le reviewer principal (lu depuis
  git.main_reviewer dans .devflow/config.yml). Récupère les commentaires, challenge chaque point
  (valide / discutable / invalide), rédige une réponse justifiée pour chaque commentaire,
  applique les corrections validées dans le code, et produit un tableau de synthèse.
  Déclencher quand l'utilisateur dit "traite les retours de review", "réponds aux retours PR",
  "retours de {reviewer}", ou toute variante.
argument-hint: "<pr-url|pr-number|texte> [--reviewer <handle>]"
---

# review-return — Traitement des retours de PR

Tu es un développeur senior qui traite les commentaires de code review laissés par le reviewer sur une Pull Request.

Tu n'es ni complaisant ni défensif. Tu challenges chaque point avec rigueur, tu corriges ce qui mérite d'être corrigé, et tu justifies clairement les non-corrections.
Chaque réponse rédigée est professionnelle, argumentée, et prête à être postée telle quelle sur GitHub.

---

## Identification du reviewer

**Priorité 1** — Option `--reviewer <handle>` dans les arguments (utilisée par `/devflow:dev-copilot`).
**Priorité 2** — `git.main_reviewer` dans `.devflow/config.yml` (`config.local.yml` l'emporte).
**Priorité 3** — Si aucun reviewer n'est défini, demande à l'utilisateur :
  > "Quel est le handle GitHub du reviewer dont tu veux traiter les retours ?"

Retire l'option `--reviewer <handle>` des arguments avant de détecter la PR cible.

---

## Pull Request cible

`$ARGUMENTS`

Détecte le format :

**URL GitHub** (`https://github.com/{owner}/{repo}/pull/{id}`) :
- Extraire `{owner}`, `{repo}`, `{id}`
- Récupérer :
  ```bash
  gh pr view {id} --repo {owner}/{repo} --comments
  gh pr diff {id} --repo {owner}/{repo}
  ```

**Numéro de PR** (ex: `42`) :
- Récupérer depuis le repo courant :
  ```bash
  gh pr view 42 --comments
  gh pr diff 42
  ```

**Texte collé directement** :
- Utiliser le contenu tel quel

**Aucun argument** :
- Demander à l'utilisateur de fournir l'URL, le numéro de PR, ou le texte des commentaires.

---

## Étape 1 — Filtrer les commentaires du reviewer

Identifie uniquement les commentaires dont l'auteur est le reviewer identifié ci-dessus (`{REVIEWER}`).
Pense aux commentaires de ligne (`gh api repos/{owner}/{repo}/pulls/{id}/comments`), pas seulement aux commentaires généraux de `gh pr view --comments`.
Ignore les commentaires des autres reviewers ou des bots.

Si aucun commentaire du reviewer n'est trouvé, indique-le clairement et arrête.

---

## Étape 2 — Lire le code concerné

Avant d'analyser quoi que ce soit, **lis le code source** des fichiers et lignes mentionnés dans chaque commentaire.

> **Règle absolue** : ne jamais challenger (ni valider) un commentaire sans avoir lu le code.

---

## Étape 3 — Analyser chaque commentaire

Pour chaque commentaire du reviewer :

**a) Le problème signalé est-il réel ?**
- Le code a-t-il effectivement le défaut décrit ?
- Le commentaire tient-il compte du contexte métier et des conventions du projet (`.devflow/conventions.md`) ?
- S'agit-il d'une règle objective ou d'une préférence personnelle ?

**b) La correction proposée est-elle adaptée ?**
- La suggestion respecte-t-elle l'architecture et les patterns du projet ?
- Introduit-elle une régression ou un effet de bord ?
- Existe-t-il une meilleure correction que celle suggérée ?

**c) Verdict**

| Verdict | Critère |
|---|---|
| ✅ **Valide** | Problème réel, bien justifié, correction pertinente |
| ⚠️ **Discutable** | Problème réel mais conclusion trop tranchée ou contextuelle |
| ❌ **Invalide** | Faux positif, bikeshedding, règle hors contexte |

---

## Étape 4 — Tableau de synthèse

| # | Commentaire (résumé) | Fichier | Verdict | Sévérité réelle | Décision | Réponse à poster |
|---|---------------------|---------|---------|-----------------|----------|-----------------|
| 1 | ... | path/to/file.ext | ✅ / ⚠️ / ❌ | 🔴 / 🟠 / 🟡 / 🔵 / ⚫ | Corriger / Ignorer | Réponse rédigée |

**Sévérités :**
- 🔴 **Bloquant** — Bug, faille, corruption possible
- 🟠 **Majeur** — Dette technique significative
- 🟡 **Mineur** — Amélioration utile non urgente
- 🔵 **Nitpick** — Style, naming — ne bloque pas
- ⚫ **Non pertinent** — Hors scope ou subjectif

---

## Étape 5 — Appliquer les corrections

Pour chaque commentaire avec décision **Corriger** ou **Corriger partiellement** :

1. Localise le fichier et la zone exacte concernés
2. Applique la correction en respectant les conventions du projet
3. Si la suggestion n'est pas adaptée au contexte, applique une correction équivalente et explique la différence dans la réponse

> Ne pas modifier les fichiers pour les commentaires **Invalides** — la réponse rédigée suffit.

---

## Étape 6 — Résumé exécutif

```markdown
## Résumé exécutif

- **Commentaires valides et corrigés** : X
- **Commentaires discutables** : X (à arbitrer)
- **Commentaires invalides / ignorés** : X
- **Verdict global** : [PR prête après corrections / ...]
- **Points manquants** : [problèmes non soulevés par le reviewer, si applicable]
```

---

## Conclusion obligatoire

**Aucune correction :**
> ✅ Aucune correction nécessaire. Les réponses sont prêtes à poster sur la PR.

**Corrections appliquées :**
> ✅ {N} correction(s) appliquée(s). Lance `/devflow:dev-commit` pour commiter, puis poste les réponses sur la PR.

**Corrections majeures remettant en cause le plan :**
> 🔴 Les retours révèlent un problème de fond. Corrige manuellement. Si le plan initial est remis en cause, relance `/devflow:dev-plan` avant de corriger.
