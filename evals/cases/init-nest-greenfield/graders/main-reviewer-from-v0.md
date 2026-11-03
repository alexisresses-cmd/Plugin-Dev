---
type: regex
pattern: "main_reviewer:\\s*[\"']?@alexis"
target: { source: file, path: .devflow/config.yml }
---
