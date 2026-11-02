---
runs: 1
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep]
expected_outcome: "Sections Testing et Tooling, modern § gates, bugfix § gates (test de reproduction)."
---
/devflow:rules gate-checker src/Service/OrderTotalCalculator.php analysis/20261102-symfony-bugfix-01.md
