---
runs: 1
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep]
expected_outcome: "php-native sans parent, section Testing, legacy § test, refactor § test (caractérisation)."
---
/devflow:rules test-writer cart.php analysis/20261102-php-legacy-refactor-01.md
