---
type: llm
focus: last_message
---
PASS si toutes ces conditions sont remplies :
1. Le plan prévoit un ADR (`docs/adr/…`) pour les choix structurants (organisation des modules, validation, gestion d'erreurs), placé avant les tâches fonctionnelles.
2. Les fondations passent avant le module `tasks` : `ValidationPipe` global (le détail de ses options n'est pas exigé : le profil les impose à l'implémentation), dépendances class-validator / class-transformer, accès Prisma injectable.
3. Le modèle Prisma `Task` et sa migration font partie du plan.
4. Le guard `x-api-key` lit la clé dans l'environnement ou la configuration (pas en dur).
5. Des tests unitaires du service et des tests e2e des routes sont prévus, dans les tâches qui écrivent le code testé ou juste après elles, et non regroupés en fin de ticket.
6. Le message demande explicitement la validation du plan ; aucune branche ni PR n'est annoncée comme créée.
FAIL si l'une des conditions manque.
