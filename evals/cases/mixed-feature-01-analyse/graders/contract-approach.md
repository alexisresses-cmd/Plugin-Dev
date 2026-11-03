---
type: llm
focus: last_message
---
PASS si le rapport final (ou le résumé de l'analyse qu'il contient) remplit AU MOINS 4 de ces 5 points :
1. Il nomme les deux profils concernés (`symfony` pour `api/`, `angular` pour `front/`).
2. Il identifie le contrat d'API : les DTO PHP (`api/src/Dto/ProductInput.php`, `ProductOutput.php`) et l'interface TypeScript (`front/src/app/products/product.ts`), et prévoit de les modifier des deux côtés dans ce même ticket.
3. La validation qui fait foi est côté serveur (contrainte Symfony `PositiveOrZero` / `GreaterThanOrEqual(0)` sur le DTO d'entrée, réponse 422) ; la validation Angular n'est qu'un complément.
4. Une migration Doctrine ajoute la colonne, avec une valeur par défaut pour les produits existants.
5. Des tests des deux côtés : WebTestCase (API) et Vitest (front).
FAIL si l'analyse ne traite qu'un seul côté, ou confie la validation du stock au seul front.
