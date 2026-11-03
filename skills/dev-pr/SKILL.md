---
name: dev-pr
description: >
  Finalise une Pull Request draft et la passe en "ready for review" : vérifie que tout est
  poussé, met à jour la description PR avec contexte / changements / comment tester / points
  d'attention pour le reviewer, puis marque la PR comme prête. Déclencher après /devflow:dev-review
  et /devflow:challenge-review quand les développements et tests sont terminés.
---

# dev-pr — Finalisation de la Pull Request

Tu es en charge de finaliser la PR et de la passer en "ready for review".
Ton objectif : que le reviewer ait tout ce qu'il faut pour comprendre et valider sans avoir à demander.

---

## Étape 1 — Vérifications préalables

```bash
git status
git log main..HEAD --oneline
git push
```

Si des modifications non committées traînent — demander de les committer d'abord.

---

## Étape 2 — Récupération du contexte

Lis dans l'historique de la conversation dans cet ordre :
1. Résultat de `/devflow:challenge-review` — verdict final et points validés
2. Résultat de `/devflow:dev-review` — points d'attention signalés
3. Résultat de `/devflow:dev-test` — scénarios de test pour le reviewer
4. Fichier `analysis/{slug}.md` — description du plan approuvé et contexte du ticket

Si rien n'est disponible, utilise :

```bash
git diff main...HEAD --stat
git log main..HEAD --oneline
```

---

## Étape 3 — Mise à jour de la description PR

```bash
gh pr view --json number,title,body
```

Template de description :

```markdown
## Contexte

[Reformulation du ticket en 2-3 phrases — pour quoi, pour qui, quel problème résolu]

## Changements

[Liste des modifications principales — fichiers clés et nature du changement]

## Comment tester

[Scénarios de test issus de /devflow:dev-test — étapes concrètes, données de test nécessaires]

## Points d'attention pour le reviewer

[Points signalés par /devflow:dev-review et validés par /devflow:challenge-review — niveau À corriger / À noter]

## Ticket

[Lien ou référence vers le ticket source]
```

Commande :

```bash
gh pr edit --body "[description complète]"
```

---

## Étape 4 — Passage en ready for review

```bash
gh pr ready
gh pr view --json url --jq '.url'
```

---

## Étape 5 — Confirmation finale

Affiche :
- **Titre** de la PR
- **Branche** source → branche cible
- **Lien URL** de la PR
- **Reviewer** à assigner (lu depuis `MAIN_REVIEWER` dans CLAUDE.md, si présent)

Si `MAIN_REVIEWER` est défini dans CLAUDE.md :

```bash
gh pr edit --add-reviewer {MAIN_REVIEWER}
```
