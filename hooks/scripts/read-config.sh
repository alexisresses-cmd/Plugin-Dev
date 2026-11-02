#!/usr/bin/env bash
# Lecture de .devflow/config.yml puis .devflow/config.local.yml (le second l'emporte), sans dépendance.
# Ne lit que des clés scalaires à deux niveaux (« section.clé »), suffisant pour les hooks (ADR 0004).

DEVFLOW_DIR="${CLAUDE_PROJECT_DIR:-$PWD}/.devflow"

_yaml_scalar() {
  local file="$1" section="${2%%.*}" key="${2#*.}"
  [[ -f "$file" ]] || return 1
  awk -v section="$section" -v key="$key" '
    /^[^[:space:]#][^:]*:/ { split($0, top, ":"); current = top[1]; next }
    current == section && $0 ~ "^[[:space:]]+" key "[[:space:]]*:" {
      value = $0
      sub("^[[:space:]]+" key "[[:space:]]*:[[:space:]]*", "", value)
      sub("[[:space:]]+#.*$", "", value)
      gsub(/^["\x27]|["\x27]$/, "", value)
      print value; found = 1; exit
    }
    END { exit found ? 0 : 1 }
  ' "$file"
}

# config_get <section.clé> <défaut> : valeur effective, ou le défaut si la clé est absente.
config_get() {
  local value
  if value="$(_yaml_scalar "$DEVFLOW_DIR/config.local.yml" "$1")"; then printf '%s' "$value"; return; fi
  if value="$(_yaml_scalar "$DEVFLOW_DIR/config.yml" "$1")"; then printf '%s' "$value"; return; fi
  printf '%s' "$2"
}

# config_enabled <section.clé> <défaut true|false> : code retour 0 si la clé vaut true.
config_enabled() {
  [[ "$(config_get "$1" "$2")" == "true" ]]
}
