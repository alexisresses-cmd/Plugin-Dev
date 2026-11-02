---
runs: 1
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Agent, Write, Edit]
expected_outcome: "Carte centrée sur le thème enfant (hooks, CPT event, AJAX mt_ajax_subscribe), conventions WordPress observées (préfixe mt_), cœur et extensions tierces identifiés comme hors périmètre."
---
/devflow:discover --yes
