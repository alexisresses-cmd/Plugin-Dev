---
runs: 1
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep]
expected_outcome: "Chaîne typescript puis angular, section Conventions avec les critères accessibilité, performance et RxJS, modern § review, feature § review, clean-code lu, api-contract non requis."
---
/devflow:rules reviewer-quality src/app/products/product-list.component.ts
