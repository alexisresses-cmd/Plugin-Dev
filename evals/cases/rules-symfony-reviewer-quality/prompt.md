---
runs: 1
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep]
expected_outcome: "Chaîne symfony → php-native, section Conventions, modern § review, feature § review, conventions.md et clean-code lus."
---
/devflow:rules reviewer-quality src/Controller/ProductController.php
