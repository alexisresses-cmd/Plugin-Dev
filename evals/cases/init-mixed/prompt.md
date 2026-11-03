---
runs: 1
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Write, Edit]
expected_outcome: "Deux blocs stacks : api/ symfony modern et front/ angular modern ; aucun mode greenfield ; .gitignore et CLAUDE.md complétés."
---
/devflow:init --yes
