---
type: regex
pattern: "\\n\\s*(-\\s+)?profile:\\s*wordpress[\\s\\S]*\\n\\s*(-\\s+)?mode:\\s*legacy|\\n\\s*(-\\s+)?mode:\\s*legacy[\\s\\S]*\\n\\s*(-\\s+)?profile:\\s*wordpress"
target: { source: file, path: .devflow/config.yml }
---
