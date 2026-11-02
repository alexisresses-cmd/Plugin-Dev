---
type: regex
pattern: "(\\n\\s+-\\s*|\\n\\s+protected:\\s*\\[[^\\]]*)[\"']?(\\./)?wp-includes/?"
target: { source: file, path: .devflow/config.yml }
---
