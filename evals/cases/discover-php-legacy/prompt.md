---
runs: 1
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Agent, Write, Edit]
expected_outcome: "Trois agents de découverte lancés ; project-map.md (pages racine et admin/, SQL concaténé, frais de port dupliqués, aucun test) et conventions.md (préfixe shop_, tabulations) écrits sans question."
---
/devflow:discover --yes
