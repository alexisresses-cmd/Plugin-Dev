---
runs: 1
max_turns: 40
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Agent]
expected_outcome: "Plan greenfield : ADR et fondations (ValidationPipe global, Prisma, guard) avant le module, tests unitaires et e2e, présenté pour validation sans action git."
---
/devflow:dev-plan analysis/20261102-nest-greenfield-feature-01.md
