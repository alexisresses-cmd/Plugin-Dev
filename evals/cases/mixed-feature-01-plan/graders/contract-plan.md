---
type: llm
focus: last_message
---
PASS si toutes ces conditions sont remplies :
1. Le contrat d'API est mis à jour des deux côtés dans ce même plan : DTO PHP (`ProductInput`, `ProductOutput`) et interface TypeScript (`front/src/app/products/product.ts`).
2. L'ordre des tâches est contrat → serveur (entité, migration Doctrine, service, contrôleur) → client (formulaire d'administration, liste avec « Rupture »).
3. La validation serveur est obligatoire (contrainte Symfony sur `ProductInput`, 422 testé) ; la validation Angular ne la remplace pas.
4. Des tests des deux côtés sont prévus : WebTestCase pour l'API et Vitest pour le front.
5. Le message demande explicitement la validation du plan ; aucune branche ni PR n'est annoncée comme créée.
FAIL si l'une des conditions manque, ou si le plan reporte l'un des deux côtés du contrat à un autre ticket.
