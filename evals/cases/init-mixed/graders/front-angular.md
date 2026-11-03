---
type: regex
pattern: "path:\\s*[\"']?(\\./)?front/?[\"']?[^\\n]*\\n(\\s+[a-z_]+:[^\\n]*\\n)*?\\s+profile:\\s*[\"']?angular\\b"
target: { source: file, path: .devflow/config.yml }
---
