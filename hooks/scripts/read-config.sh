#!/usr/bin/env bash
# Lecture de .devflow/config.yml puis .devflow/config.local.yml (le second l'emporte), sans dépendance.
# Lit les clés scalaires à deux niveaux (« section.clé ») et les listes stacks[].wordpress.protected (ADR 0004).

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

# Parcourt stacks[] d'un fichier : « S<TAB>path » par bloc (hors racine), « P<TAB>chemin » par entrée de
# wordpress.protected, relative à la racine et, si le bloc a un path, aussi relative à ce path.
# Listes acceptées : à tirets (même indentation que la clé ou plus) ou inline « [a, b] ».
_yaml_stacks() {
  [[ -f "$1" ]] || return 0
  awk '
    function unquote(s) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", s); gsub(/^["\047]|["\047]$/, "", s); return s }
    function norm(p) { p = unquote(p); sub(/^\.\//, "", p); sub(/\/+$/, "", p); return p == "." ? "" : p }
    function add(p) { p = norm(p); if (p != "") entries[++n] = p }
    function flush(   i, base) {
      if (in_item) {
        base = norm(path)
        if (base != "") print "S\t" base
        for (i = 1; i <= n; i++) { print "P\t" entries[i]; if (base != "") print "P\t" base "/" entries[i] }
      }
      n = 0; path = ""; in_item = 0; prot_indent = -1
    }
    BEGIN { item_indent = -1; prot_indent = -1 }
    {
      line = $0
      if (line ~ /^[[:space:]]*(#|$)/) next
      sub(/[[:space:]]+#.*$/, "", line)
      match(line, /^[[:space:]]*/); indent = RLENGTH; content = substr(line, indent + 1)
      if (indent == 0 && content !~ /^-/) { flush(); in_stacks = (content ~ /^stacks[[:space:]]*:/); item_indent = -1; next }
      if (!in_stacks) next
      if (content ~ /^-([[:space:]]|$)/) {
        if (item_indent < 0) item_indent = indent
        if (indent == item_indent) {
          flush(); in_item = 1
          content = substr(content, 2); match(content, /^[[:space:]]*/)
          indent += 1 + RLENGTH; content = substr(content, RLENGTH + 1)
          if (content == "") next
        } else if (prot_indent >= 0 && indent >= prot_indent) { add(substr(content, 2)); next }
      }
      if (prot_indent >= 0 && indent <= prot_indent) prot_indent = -1
      if (content ~ /^path[[:space:]]*:/ && path == "") { path = content; sub(/^path[[:space:]]*:/, "", path) }
      if (content ~ /^protected[[:space:]]*:/) {
        value = content; sub(/^protected[[:space:]]*:[[:space:]]*/, "", value)
        if (value ~ /^\[/) { gsub(/^\[|\][[:space:]]*$/, "", value); k = split(value, parts, ","); for (i = 1; i <= k; i++) add(parts[i]) }
        else prot_indent = indent
      }
    }
    END { flush() }
  ' "$1"
}

# config_protected_paths : chemins protégés, relatifs à la racine du projet, sans « / » final, un par ligne.
# Les listes de config.yml et de config.local.yml s'additionnent : la configuration locale ne peut pas
# retirer une protection décidée par l'équipe.
config_protected_paths() {
  { _yaml_stacks "$DEVFLOW_DIR/config.yml"; _yaml_stacks "$DEVFLOW_DIR/config.local.yml"; } \
    | awk -F '\t' '$1 == "P" && !seen[$2]++ { print $2 }'
}

# config_stack_paths : path des blocs stacks[] de config.yml (hors racine). config.local.yml est ignoré :
# un path sert d'exception aux protections, il ne doit pas pouvoir les alléger localement.
config_stack_paths() {
  _yaml_stacks "$DEVFLOW_DIR/config.yml" | awk -F '\t' '$1 == "S" && !seen[$2]++ { print $2 }'
}
