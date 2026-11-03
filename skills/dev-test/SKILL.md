---
name: dev-test
description: >
  Fait écrire par l'agent test-writer les tests automatisés de la logique modifiée sur la branche
  (PHPUnit si présent, sinon scripts PHP sans framework) et un plan de test manuel, puis commite
  les tests. Déclencher après /devflow:dev-implement et avant /devflow:dev-review.
argument-hint: "[analysis/YYYYMMDD-slug.md]"
---

# dev-test — Tests de la branche

1. **Contexte** : fichier d'analyse (`$ARGUMENTS`, sinon celui de la session ou le plus récent dont le `status` vaut `planned`). Branche de base : `main`, sinon `master`.
2. **Agent** : lance `devflow:test-writer` avec la branche de base et le chemin du fichier d'analyse.
3. **Fichier d'analyse** : ajoute ou remplace la section `## Plan de test manuel` avec le champ `manual_plan` renvoyé par l'agent.
4. **Commit** : si des fichiers de test ont été créés, invoque `devflow:dev-commit` (type `test`).
5. **Bilan** :

```
✅ Tests — {framework}
Fichiers : {test_files} — {test_cases_count} cas
Exécution : {run.command} → {run.status}
Plan manuel : {nombre} scénarios (dans analysis/{fichier}.md)
⚠️ {warnings, échecs}

Prochaine étape : /devflow:dev-review
```

Si `run.status` vaut `fail`, liste les échecs et demande à l'utilisateur s'il faut corriger le code avant la review. Ne corrige rien sans son accord.
