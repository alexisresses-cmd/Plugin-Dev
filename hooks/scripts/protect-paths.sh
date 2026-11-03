#!/usr/bin/env bash
# PreToolUse : refuse toute modification d'un chemin listé dans stacks[].wordpress.protected.
# Règle : une entrée protège <racine>/<entrée> et, pour un bloc dont le path n'est pas la racine,
# <racine>/<path>/<entrée>. Le path d'un bloc de config.yml reste modifiable même s'il se trouve sous
# une entrée protégée (l'extension elle-même sous wp-content/plugins/). config.local.yml ajoute des
# protections, il n'en retire jamais.
# Bash : redirections > et >>, sed -i, perl -i, cp/install/ln (destination), mv, rm, rmdir, unlink,
# shred, tee, touch, truncate, dd of=. Un « cd » préalable n'est pas suivi : les chemins relatifs sont
# résolus depuis le cwd du hook.
set -u
source "$(dirname "$0")/lib.sh"
source "$(dirname "$0")/read-config.sh"

PROTECTED=(); STACK_PATHS=()
while IFS= read -r line; do PROTECTED+=("$line"); done < <(config_protected_paths)
[[ ${#PROTECTED[@]} -eq 0 ]] && exit 0
while IFS= read -r line; do STACK_PATHS+=("$line"); done < <(config_stack_paths)

REDIRECTION_RE='[0-9]*>{1,2}[[:space:]]*([^[:space:];&|]+)'
IN_PLACE_RE='[[:space:]](-[a-zA-Z]*i[a-zA-Z.]*|--in-place[^[:space:]]*)[[:space:]]'
TARGET_DIR_RE='(-t[[:space:]]*|--target-directory=)([^[:space:]]+)'

# normalize <chemin absolu> : résout « . », « .. » et les « / » multiples, sans toucher au disque.
normalize() {
  local part out=() parts=()
  IFS='/' read -ra parts <<< "$1"
  for part in ${parts[@]+"${parts[@]}"}; do
    case "$part" in
      ''|.) ;;
      ..) [[ ${#out[@]} -gt 0 ]] && unset "out[$((${#out[@]} - 1))]" ;;
      *) out+=("$part") ;;
    esac
  done
  local IFS=/
  printf '/%s' "${out[*]-}"
}

ROOT="$(normalize "${CLAUDE_PROJECT_DIR:-$PWD}")"
CWD="$(json_get .cwd)"
[[ -z "$CWD" ]] && CWD="$ROOT"

# relative <chemin> : chemin relatif à la racine du projet (vide pour la racine) ; échec s'il est hors du projet.
relative() {
  local path="${1/#\~/$HOME}"
  [[ "$path" != /* ]] && path="$CWD/$path"
  path="$(normalize "$path")"
  [[ "$path" == "$ROOT" ]] && return 0
  [[ "$path" == "$ROOT"/* ]] || return 1
  printf '%s' "${path#"$ROOT"/}"
}

# exempt <rel> <entrée> : rel est dans le path d'un bloc situé sous l'entrée protégée.
exempt() {
  local stack
  for stack in ${STACK_PATHS[@]+"${STACK_PATHS[@]}"}; do
    [[ "$stack" == "$2"/* && ( "$1" == "$stack" || "$1" == "$stack"/* ) ]] && return 0
  done
  return 1
}

refuse() {
  deny "modification refusée : « $1 » est dans un chemin protégé ($2/, wordpress.protected de .devflow/config.yml). Ne modifie jamais le cœur WordPress, une extension ou un thème tiers : passe par un hook (add_action / add_filter), le thème enfant ou une extension dédiée. Si la modification est vraiment voulue, demande à l'utilisateur de la faire lui-même."
}

# check <chemin> [destructif] : refuse si le chemin est protégé, ou, pour une suppression ou un
# déplacement, s'il contient un chemin protégé.
check() {
  local rel entry
  rel="$(relative "$1")" || return 0
  for entry in "${PROTECTED[@]}"; do
    if [[ "$rel" == "$entry" || "$rel" == "$entry"/* ]]; then
      exempt "$rel" "$entry" || refuse "$1" "$entry"
    elif [[ -n "${2:-}" && ( -z "$rel" || "$entry" == "$rel"/* ) ]]; then
      refuse "$1" "$entry"
    fi
  done
}

check_segment() {
  local segment="$1" word words=() args=() destructive=""
  while [[ "$segment" =~ $REDIRECTION_RE ]]; do
    check "${BASH_REMATCH[1]//[\"\']/}"
    segment="${segment/"${BASH_REMATCH[0]}"/ }"
  done

  read -ra words <<< "${segment//[\"\']/}"
  local i=0
  while [[ $i -lt ${#words[@]} && ( "${words[$i]}" == *=* || "${words[$i]}" =~ ^(sudo|env|command|exec)$ ) ]]; do i=$((i+1)); done
  [[ $i -ge ${#words[@]} ]] && return
  local cmd="${words[$i]##*/}" rest=" ${words[*]:$((i+1))} "
  for word in "${words[@]:$((i+1))}"; do
    [[ "$word" == -* ]] || args+=("$word")
  done
  case "$cmd" in
    sed|perl) [[ "$rest" =~ $IN_PLACE_RE ]] || return ;;
    cp|install|ln)
      if [[ "$rest" =~ $TARGET_DIR_RE ]]; then
        args=("${BASH_REMATCH[2]}")
      elif [[ ${#args[@]} -gt 0 ]]; then
        args=("${args[$((${#args[@]} - 1))]}")
      fi ;;
    mv|rm|rmdir|unlink|shred) destructive=1 ;;
    tee|touch|truncate) ;;
    dd)
      for word in ${args[@]+"${args[@]}"}; do [[ "$word" == of=* ]] && check "${word#of=}"; done
      return ;;
    *) return ;;
  esac
  for word in ${args[@]+"${args[@]}"}; do
    check "$word" "$destructive"
  done
}

tool="$(json_get .tool_name)"

if [[ "$tool" == "Bash" ]]; then
  while IFS= read -r segment; do
    check_segment "$segment"
  done <<< "$(json_get .tool_input.command | strip_heredocs | sed -E 's/(&&|\|\||;|\|)/\n/g')"
  exit 0
fi

[[ "$tool" =~ ^(Edit|Write|MultiEdit|NotebookEdit)$ ]] || exit 0
path="$(json_get .tool_input.file_path)"
[[ -z "$path" ]] && path="$(json_get .tool_input.notebook_path)"
[[ -n "$path" ]] && check "$path"
exit 0
