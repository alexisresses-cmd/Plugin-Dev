# Mode greenfield

> Projet neuf ou module créé de zéro. Principe : **poser les bonnes fondations**, appliquer la stack idéale à la lettre.

## analyse
- Pas d'analyse de l'existant (ou très légère) : se concentrer sur les **choix d'architecture** (structure, découpage en modules, gestion d'erreurs, validation, persistance).

## plan
- Prévoir explicitement : structure des dossiers, outillage (tests, lint, analyse statique, CI) s'il manque, et un **ADR** par choix structurant (`templates/adr.md` du plugin).
- Les tâches d'outillage passent avant les tâches fonctionnelles.

## implement
- Conventions de la stack **à la lettre**, typage strict, aucune dette volontaire.

## test
- Tests **dès le départ**, écrits avec le code. Objectif : 80 % de couverture de lignes sur le code nouveau si l'outil le mesure.

## review
- Revue **complète et stricte** : un écart aux conventions de la stack est au moins `should-fix`.

## simplifier
- **Agressif** sur le code de la branche : supprimer toute abstraction prématurée et tout code non utilisé.

## gates
- Seuils stricts : tests verts, zéro erreur de lint et d'analyse statique (pas de baseline), couverture visée atteinte si mesurée.

## pr
- Lister les ADR créés et l'outillage mis en place.
