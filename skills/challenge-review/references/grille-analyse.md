# Grille d'analyse — Challenge par catégorie

## 🔐 Sécurité

- Est-ce un vrai vecteur d'attaque, ou théorique sans exploitabilité réelle ?
- Y a-t-il une CVE, OWASP Top 10, ou CWE qui s'applique explicitement ici ?
- Le fix proposé crée-t-il lui-même un problème ?
- Confusion entre donnée contrôlée (input interne) et non contrôlée (user input) ?

**Faux positifs fréquents :** règle SAST générique hors contexte, "ça pourrait être un risque si..." sans scénario concret.

## ⚡ Performance

- Y a-t-il un benchmark ou profiler qui montre le problème, ou c'est une intuition ?
- Ce code path est-il sur le hot path ou rarement appelé ?
- La complexité algorithmique est-elle un vrai problème à l'échelle actuelle ?
- La lisibilité sacrifiée vaut-elle le coût de maintenance ?

**Faux positifs fréquents :** micro-optimisation sur code path froid, O(n²) sur dataset dont la taille max est petite et connue.

## 🏗️ Architecture & Design

- Le problème de design est réel, ou le reviewer préfère son pattern favori ?
- L'abstraction suggérée est justifiée par un besoin réel, ou spéculative (YAGNI) ?
- Le changement proposé est-il proportionnel au scope de la PR ?

**Faux positifs fréquents :** "il faudrait une factory/strategy ici" sur un use case unique, refactoring majeur hors scope.

## 🧪 Tests

- Le cas manquant couvre-t-il un vrai edge case atteignable en prod ?
- Le test suggéré est-il un test de comportement ou de l'implémentation (brittle) ?
- La couverture manquante concerne une branche critique ou triviale ?

**Faux positifs fréquents :** test de getter/setter, cas impossible par construction (type fort, enum exhaustif).

## 📖 Lisibilité & Maintenabilité

- Le code est-il objectivement difficile à comprendre, ou juste non familier au reviewer ?
- Le naming est-il ambigu dans le domaine métier, ou seulement dans le domaine du reviewer ?
- Le commentaire demandé apporte-t-il de l'information, ou paraphrase-t-il le code ?

**Faux positifs fréquents :** "je préfère nommer ça autrement" sans argument de clarté, demande de commentaires sur code auto-documenté.

## 🎨 Style & Conventions

- Y a-t-il une règle linter/formatter configurée dans le projet qui l'interdit ?
- Est-ce dans le guide de style officiel de l'équipe/langage ?
- Si aucune des deux → **nitpick par défaut**, pas un "major".

## 🔄 Gestion d'erreurs & Edge cases

- Le cas non géré peut-il réellement se produire avec les invariants du système ?
- La gestion d'erreur est-elle dans le scope de cette PR ou d'un layer supérieur ?

**Faux positifs fréquents :** "et si X est null ?" sur un paramètre garanti non-null par le type system ou la logique amont.
