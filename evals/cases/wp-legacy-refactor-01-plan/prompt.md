---
runs: 1
max_turns: 40
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Agent]
expected_outcome: "Plan en petites étapes, caractérisation d'abord (G0, Brain Monkey ou scripts), requête concaténée signalée, nonce et current_user_can conservés, rien hors du thème enfant."
---
/devflow:dev-plan analysis/20261102-wp-legacy-refactor-01.md
