# Mode legacy

> Code existant ancien, peu ou pas testé, conventions hétérogènes. Principe : **ne pas aggraver, ne pas refondre hors périmètre**. Les conventions observées priment sur les conventions idéales de la stack.

## analyse
- Partir de `.devflow/project-map.md` s'il existe ; sinon, signaler qu'un `/devflow:discover` aiderait.
- Rechercher activement : code mort, couplages cachés (globales, includes en cascade, SQL partagé entre pages), effets de bord (sessions, caches, fichiers).
- Lister les autres points d'appel des fonctions touchées (Grep) : en legacy, une fonction est souvent réutilisée là où on ne l'attend pas.

## plan
- **Changement minimal** : aucune tâche de refactoring hors du périmètre du ticket.
- Si le code touché n'a pas de test : prévoir une tâche de tests de caractérisation, ou un plan de test manuel renforcé si l'infrastructure de test est absente.
- Toute dette repérée va dans « Hors périmètre », avec une proposition de ticket.

## implement
- **Imiter les conventions observées** dans le fichier et ses voisins (indentation, nommage, préfixes, style d'accès aux données), même si elles diffèrent de la stack.
- Le **nouveau** code respecte les règles de sécurité de la stack (requêtes préparées, échappement) sans réécrire le code existant non touché.
- Nettoyage limité aux lignes modifiées par le ticket.

## test
- **Tests de caractérisation d'abord** : figer le comportement actuel de la zone touchée avant de la modifier.
- Sans framework de test : scripts PHP autonomes, ou plan de test manuel renforcé (non-régression détaillée des écrans voisins).

## review
- Juger **le diff seul**. La dette existante est signalée en `note`, jamais en `blocking`.
- Focus sur les **régressions** : autres appelants, comportements implicites, données existantes.
- Ne pas exiger les conventions idéales de la stack quand le code suit la convention observée du fichier.

## simplifier
- **Prudent** : réduire le diff uniquement ; ne jamais toucher au code existant, même s'il est dupliqué.

## gates
- **Règle du cliquet** : ne pas aggraver. Pour l'analyse statique et le lint, comparer les erreurs **sur les fichiers modifiés** entre la base et la branche (ou utiliser `tooling.static_analysis_baseline`) : FAIL seulement s'il y a des erreurs nouvelles. Les erreurs préexistantes ne bloquent pas.
- Tests : les tests existants passent ; l'absence de tests n'est pas un FAIL si le plan de test manuel existe.

## pr
- Mentionner la dette repérée mais non traitée et les tickets proposés.
- Détailler le plan de test manuel (non-régression).
