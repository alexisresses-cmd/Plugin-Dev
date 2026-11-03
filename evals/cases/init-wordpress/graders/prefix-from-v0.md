---
type: regex
pattern: "branch_prefix:\\s*[\"']?feature/"
target: { source: file, path: .devflow/config.yml }
---
