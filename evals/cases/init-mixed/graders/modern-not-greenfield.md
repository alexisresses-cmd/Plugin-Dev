---
type: regex
pattern: "^(?![\\s\\S]*\\n\\s*mode:\\s*[\"']?(greenfield|legacy))[\\s\\S]*\\n\\s*mode:\\s*[\"']?modern[\\s\\S]*\\n\\s*mode:\\s*[\"']?modern"
target: { source: file, path: .devflow/config.yml }
---
