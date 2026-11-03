---
runs: 1
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Agent, Write]
expected_outcome: "Analyse greenfield centrée sur les choix d'architecture : ADR, DTO + ValidationPipe global, Prisma, guard x-api-key, tests unitaires et e2e."
---
/devflow:dev-analyse #7 — Créer le module `tasks` : CRUD de tâches (`title` requis ≤ 120 car., `done` booléen, `dueDate` optionnelle), protégé par un guard qui exige un en-tête `x-api-key`.
