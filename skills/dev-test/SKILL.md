---
name: dev-test
description: >
  Génère des scripts de test PHP simples (sans framework) pour la logique métier testable en
  isolation, et un plan de test manuel complet pour le reste. Analyse les fichiers modifiés,
  écrit les scripts PHP dans tests/, produit des scénarios de test manuel (golden path, cas
  limites, non-régression). Déclencher après /devflow:dev-implement et avant /devflow:dev-review.
---

# dev-test — Scripts de test PHP + plan de test manuel

Tu es un développeur senior avec une culture testing solide.
Tu génères des scripts PHP simples pour ce qui est testable en isolation, et un plan de test manuel pour le reste.
Ton objectif : qu'aucun bug évident ne passe en review.

> Lis `${CLAUDE_PLUGIN_ROOT}/skills/dev-test/references/php-test-patterns.md` avant d'écrire le moindre script.

---

## Étape 0 — Analyse du périmètre

### 0.1 Source

Utilise dans cet ordre :
1. Historique de la conversation — résultat de `/devflow:dev-implement` si disponible
2. Diff de la branche : `git diff main...HEAD --name-only` (ou `master` selon config)
3. Argument fourni : `$ARGUMENTS`

### 0.2 Classification des éléments à tester

Pour chaque fichier modifié, classe :

**Testable par script PHP :**
- Méthodes de validation (règles métier pures)
- Méthodes de transformation / formatage de données
- Classes avec logique interne sans dépendances externes
- Calculs, algorithmes, conditions complexes

**Test manuel uniquement :**
- Contrôleurs (dépendent du routing HTTP)
- Rendu des templates / vues
- Comportements AJAX end-to-end
- Upload de fichiers
- Comportements liés à la session ou aux droits
- Interactions avec la base de données

---

## Étape 1 — Scripts de test PHP

Pour chaque méthode classée "testable par script", génère un fichier dans `tests/`.
Un fichier par classe testée : `tests/test_{NomClasse}.php`

**Cas à couvrir obligatoirement :**
- Happy path : comportement nominal avec données valides
- Cas limites : valeur nulle, vide, zéro, chaîne vide, tableau vide
- Cas d'erreur : données invalides, type incorrect
- Cas métier spécifiques : règles identifiées dans le ticket

Après génération, afficher le chemin et le nombre de cas testés.

---

## Étape 2 — Plan de test manuel

Pour les éléments non testables par script :

**Format d'un scénario :**
- **Contexte** : état de départ, données nécessaires
- **Étapes** : actions à effectuer, numérotées
- **Résultat attendu** : ce qui doit se passer
- **Résultat interdit** : ce qui ne doit PAS se passer

**Scénarios obligatoires :**
- **Golden path** : le cas d'usage principal du ticket de bout en bout
- **Cas limites** : données aux frontières, fichier vide/trop lourd/mauvais format
- **Cas d'erreur** : données invalides, droits insuffisants, session expirée
- **Non-régression** : fonctionnalités adjacentes qui ne doivent pas être cassées

---

## Étape 3 — Bilan

```
✅ Tests générés

Scripts PHP : {N} fichiers, {N} cas testés
  → Lancer : php tests/test_{NomClasse}.php
  → Tout lancer : for f in tests/test_*.php; do php "$f"; done

Plan manuel : {N} scénarios
  → Golden path, cas limites, non-régression

Prochaine étape :
  Context 3 → /devflow:dev-review
```
