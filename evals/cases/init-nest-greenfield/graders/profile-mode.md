---
type: regex
pattern: "\\n\\s*(-\\s+)?profile:\\s*[\"']?nestjs\\b[\\s\\S]*\\n\\s*(-\\s+)?mode:\\s*[\"']?greenfield|\\n\\s*(-\\s+)?mode:\\s*[\"']?greenfield[\\s\\S]*\\n\\s*(-\\s+)?profile:\\s*[\"']?nestjs\\b"
target: { source: file, path: .devflow/config.yml }
---
