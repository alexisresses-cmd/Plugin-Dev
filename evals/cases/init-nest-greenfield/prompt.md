---
runs: 1
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Write, Edit]
expected_outcome: "config.yml nestjs/greenfield (code applicatif quasi vide), préfixe et reviewer repris du CLAUDE.md v0, section devflow ajoutée sans perte."
---
/devflow:init --yes
