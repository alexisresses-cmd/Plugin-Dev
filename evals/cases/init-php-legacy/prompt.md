---
runs: 1
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Write, Edit]
expected_outcome: "php-native en mode legacy (pas de Composer, pas de tests, pas de namespaces), préfixe fix/."
---
/devflow:init --yes
