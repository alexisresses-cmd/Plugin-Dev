---
runs: 1
max_turns: 50
timeout_seconds: 3000
allowed_tools: [Read, Glob, Grep, Skill, Agent, Edit, Write, Bash]
expected_outcome: "Voie rapide, faute corrigée, aucun reviewer ni test-writer."
---
/devflow:dev-cycle analysis/20261102-symfony-fastlane-01-planned.md
