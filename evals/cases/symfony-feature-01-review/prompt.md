---
runs: 1
max_turns: 80
timeout_seconds: 2400
allowed_tools: [Read, Glob, Grep, Skill, Agent, Edit, Write, Bash]
expected_outcome: "Les reviewers trouvent l'absence de contrôle d'accès sur archive (bloquant), le challenger le confirme, la correction automatique ajoute le contrôle et G2 passe."
---
/devflow:dev-review analysis/20261102-symfony-feature-01.md
