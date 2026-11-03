---
name: dev-copilot
description: >
  Traite les commentaires de review laissés par GitHub Copilot sur une Pull Request :
  filtre les commentaires du bot Copilot, les challenge (valide / discutable / invalide),
  applique les corrections justifiées et rédige les réponses. Déclencher quand l'utilisateur dit
  "traite les retours Copilot", "réponds à Copilot", "/devflow:dev-copilot".
argument-hint: "<pr-url|pr-number>"
---

# dev-copilot — Traitement des retours de GitHub Copilot

Ce skill applique la procédure de `devflow:review-return` (lis `${CLAUDE_PLUGIN_ROOT}/skills/review-return/SKILL.md` et suis ses étapes 1 à 6) avec ces différences.

## 1. Reviewer

Le reviewer est le bot Copilot. Selon l'API, son login est `copilot-pull-request-reviewer[bot]`, `copilot-pull-request-reviewer` ou `Copilot`. Retiens les commentaires dont l'auteur correspond à l'une de ces valeurs.

Récupère les commentaires de ligne, où Copilot écrit l'essentiel de ses remarques :

```bash
gh api repos/{owner}/{repo}/pulls/{id}/comments --paginate \
  --jq '.[] | select(.user.login | test("copilot"; "i")) | {id, path, line, body}'
gh api repos/{owner}/{repo}/pulls/{id}/reviews \
  --jq '.[] | select(.user.login | test("copilot"; "i")) | {id, body}'
```

PR cible : `$ARGUMENTS`. Sans argument, prends la PR de la branche courante (`gh pr view --json number`).

## 2. Posture spécifique à Copilot

Copilot n'a pas le contexte du ticket ni les conventions du projet. Avant de juger un commentaire, vérifie en particulier :
- **Suggestions de code** (blocs `suggestion`) : la suggestion compile-t-elle et respecte-t-elle les conventions de `CLAUDE.md` ? Ne l'applique jamais telle quelle sans l'avoir relue.
- **Faux positifs fréquents** : null-check sur une valeur garantie par le typage, demande de commentaire sur du code auto-documenté, renommage cosmétique, gestion d'erreur déjà assurée par une couche supérieure. Reprends les patterns de `${CLAUDE_PLUGIN_ROOT}/skills/challenge-review/references/patterns-bikeshedding.md`.
- **Vrais positifs fréquents** : faute de frappe, condition inversée, ressource non libérée, variable inutilisée, incohérence entre docblock et signature.

## 3. Réponses

Les réponses sont courtes et factuelles (Copilot ne lit pas les réponses ; elles servent aux humains qui relisent la PR) :
- **Corrigé** : « Corrigé dans {hash-court}. »
- **Non retenu** : une phrase de justification technique.

## 4. Conclusion

Même conclusion que `review-return`. Les corrections sont commitées via `/devflow:dev-commit`.
