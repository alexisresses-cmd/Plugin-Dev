---
type: regex
pattern: "path:\\s*[\"']?(\\./)?api/?[\"']?[^\\n]*\\n(\\s+[a-z_]+:[^\\n]*\\n)*?\\s+profile:\\s*[\"']?symfony\\b"
target: { source: file, path: .devflow/config.yml }
---
