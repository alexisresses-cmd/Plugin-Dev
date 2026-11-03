---
runs: 1
max_turns: 40
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Agent]
expected_outcome: "Plan synthétisé à partir des deux planners et du challenger, présenté pour validation, sans aucune action git."
---
/devflow:dev-plan analysis/20261102-symfony-feature-01.md
