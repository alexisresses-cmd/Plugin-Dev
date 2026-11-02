---
type: regex
pattern: "branch_prefix:\\s*[\"']?fix/"
target: { source: file, path: .devflow/config.yml }
---
