---
type: llm
focus: last_message
---
PASS si le rapport final (ou le résumé de l'analyse qu'il contient) couvre AU MOINS 4 de ces 5 points :
1. Des choix d'architecture posés pour un projet neuf (organisation en modules, validation, gestion d'erreurs), avec un ADR proposé pour les choix structurants.
2. Des DTO class-validator et un `ValidationPipe` global avec `whitelist` et `forbidNonWhitelisted` (ou équivalent explicite : refus des champs inconnus).
3. Un modèle Prisma `Task` et une migration Prisma.
4. Un guard sur l'en-tête `x-api-key`, clé lue dans l'environnement ou la configuration (jamais en dur), idéalement comparée à temps constant.
5. Des tests unitaires du service et des tests e2e (`Test.createTestingModule`, Supertest).
FAIL si l'analyse traite le projet comme legacy (imiter l'existant, pas de tests), propose `any` sans justification, ou ne mentionne aucun de ces points.
