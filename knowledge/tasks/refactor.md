# Type de tâche : refactor

> Principe : **aucun changement fonctionnel**. Un bug découvert pendant un refactoring est **signalé** (proposition de ticket séparé), jamais corrigé dans la même PR.

## analyse
- Dette visée, dépendances de la zone (appelants, données), risques de régression.
- Identifier les comportements surprenants existants (incohérences, cas limites) : ils devront être **préservés** et signalés.

## plan
- **Petites étapes réversibles** (méthode Mikado) : chaque étape laisse le code fonctionnel.
- **Une transformation par tâche** : une extraction (fonction, classe, méthode) ou un déplacement par tâche, jamais plusieurs extractions regroupées dans la même tâche.
- Première tâche : **tests de caractérisation automatisés** de la zone (gate **G0**), avant toute modification d'un fichier de production. Sans framework de test : scripts PHP autonomes (repli du profil). Un plan de test manuel ne remplace **jamais** ces tests pour un refactor, même en mode legacy.
- Gros chantier : strangler fig ou branch by abstraction, en plusieurs PR.

## implement
- **Une transformation par commit**, tests verts à chaque commit.
- Aucune modification de comportement, même pour « corriger » une incohérence : la signaler.

## test
- Tests de caractérisation **automatisés, avant toute modification** : ils décrivent le comportement actuel, y compris les cas surprenants, et passent sur le code initial. Cette règle prime sur l'option « plan de test manuel » du mode legacy.

## review
- **Équivalence de comportement** : tout changement fonctionnel est `blocking`.
- Vérifier que les incohérences existantes sont préservées et signalées, pas corrigées.

## simplifier
- Plus libre **dans le périmètre** du refactoring ; toujours à comportement identique.

## gates
- **G0** avant l'implémentation : tests de caractérisation présents pour la zone touchée, verts sur le code initial, aucun fichier de production encore modifié.
- G1 vérifie en plus que les tests de caractérisation passent à chaque commit (au minimum sur le dernier).
- G2 standard.

## pr
- Avant / après (structure), **preuve d'équivalence** (tests de caractérisation, exécution), bugs repérés et tickets proposés.
- Si le refactoring a ajouté de l'outillage (tests, analyse statique), proposer de **requalifier le mode** du projet (ex. legacy → modern) dans `.devflow/config.yml`.
