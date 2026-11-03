---
runs: 1
max_turns: 50
timeout_seconds: 1500
allowed_tools: [Read, Glob, Grep, Skill, Agent]
expected_outcome: "Plan fusionné des deux planners et challengé : contrat des deux côtés dans le même ticket, ordre contrat → serveur → client, validation serveur, tests WebTestCase et Vitest."
---
/devflow:dev-plan analysis/20261102-mixed-feature-01.md
