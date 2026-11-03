---
runs: 1
max_turns: 120
timeout_seconds: 3000
allowed_tools: [Read, Glob, Grep, Skill, Agent, Edit, Write, Bash]
expected_outcome: "G0 (tests de caractérisation) avant toute modification, refactoring équivalent, écart préservé."
---
/devflow:dev-cycle analysis/20261102-php-legacy-refactor-01-planned.md
