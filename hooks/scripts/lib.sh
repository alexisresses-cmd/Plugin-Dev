#!/usr/bin/env bash
# Fonctions communes aux hooks devflow. Lit l'entrée JSON du hook une seule fois.

HOOK_INPUT="$(cat)"

# json_get <expression jq> : extrait une valeur texte de l'entrée du hook (vide si absente).
json_get() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$HOOK_INPUT" | jq -r "($1) // empty" 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$HOOK_INPUT" | python3 -c '
import json, sys
data = json.load(sys.stdin)
for key in sys.argv[1].lstrip(".").split("."):
    data = data.get(key) if isinstance(data, dict) else None
print("" if data is None else data if isinstance(data, str) else json.dumps(data))
' "$1" 2>/dev/null
  else
    echo "devflow: jq ou python3 requis par les hooks ; contrôle ignoré" >&2
    exit 0
  fi
}

# deny <raison> : refuse l'appel d'outil (PreToolUse) en expliquant pourquoi à Claude.
deny() {
  echo "devflow: $1" >&2
  exit 2
}

# Retire le corps des heredocs : c'est du contenu, pas des fichiers manipulés.
strip_heredocs() {
  awk '
    terminator != "" { line = $0; sub(/^\t+/, "", line); if (line == terminator) terminator = ""; next }
    match($0, /<<-?[[:space:]]*["\x27]?[A-Za-z_][A-Za-z0-9_]*/) {
      terminator = substr($0, RSTART, RLENGTH); gsub(/^<<-?[[:space:]]*["\x27]?/, "", terminator)
    }
    { print }
  '
}
