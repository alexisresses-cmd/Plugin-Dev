---
type: regex
pattern: "(\\n\\s+-\\s*|\\n\\s+protected:\\s*\\[[^\\]]*)[\"']?(\\./)?wp-content/themes/parent-theme/?"
target: { source: file, path: .devflow/config.yml }
---
