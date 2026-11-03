---
runs: 1
max_turns: 30
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Agent, Write]
expected_outcome: "Triage S, seul code-mapper est lancé."
---
/devflow:dev-analyse #61 — Faute de frappe dans le message de validation de Product::$name : « Le nom est obligatoir ».
