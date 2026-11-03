---
runs: 1
max_turns: 40
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Agent]
expected_outcome: "Plan en petites étapes, caractérisation d'abord (G0), écart > / >= préservé et signalé."
---
/devflow:dev-plan analysis/20261102-php-legacy-refactor-01.md
