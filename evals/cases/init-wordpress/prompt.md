---
runs: 1
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Write, Edit]
expected_outcome: "wordpress en mode legacy sur le thème enfant (type child-theme), cœur, extensions et thème parent protégés, préfixe feature/."
---
/devflow:init --yes
