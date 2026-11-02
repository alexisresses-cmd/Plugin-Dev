#!/usr/bin/env bash
# PreToolUse : empêche de lire, écrire ou manipuler en shell les fichiers de secrets.
set -u
source "$(dirname "$0")/lib.sh"
source "$(dirname "$0")/read-config.sh"
config_enabled hooks.block_secrets true || exit 0

ALLOWED_ENV_SUFFIX='example|dist|sample|template|test'
FILE_COMMANDS='cat|tac|less|more|head|tail|source|\.|cp|mv|rsync|scp|tee|vi|vim|nano|code|grep|egrep|rg|sed|awk|cut|sort|diff|base64|xxd|strings|openssl|ln|chmod|chown|rm|touch|truncate|dd|zip|tar|curl'
GIT_FILE_SUBCOMMANDS='add|show|diff|checkout|restore|rm|mv|cat-file|log|blame|stash'

is_secret_name() {
  local name="${1##*[/:]}"
  case "$name" in
    .env|.env.local|wp-config.php|parameters.yml|id_rsa|id_ed25519|*.pem|*.key|*.p12|*.pfx) return 0 ;;
    .env.*) [[ ! "$name" =~ ^\.env\.($ALLOWED_ENV_SUFFIX)$ ]] && return 0 ;;
  esac
  return 1
}

refuse() {
  deny "commande refusée : elle vise un fichier de secrets ($1). Demande à l'utilisateur de le faire lui-même si c'est nécessaire."
}

check_segment() {
  local segment="$1" target word
  while [[ "$segment" =~ [0-9]*[\<\>]{1,2}[[:space:]]*([^[:space:]\;\&\|]+) ]]; do
    target="${BASH_REMATCH[1]//[\"\']/}"
    is_secret_name "$target" && refuse "$target"
    segment="${segment/"${BASH_REMATCH[0]}"/ }"
  done

  read -ra words <<< "${segment//[\"\']/}"
  local i=0
  while [[ $i -lt ${#words[@]} && ( "${words[$i]}" == *=* || "${words[$i]}" =~ ^(sudo|env|command|exec)$ ) ]]; do i=$((i+1)); done
  [[ $i -ge ${#words[@]} ]] && return
  local cmd="${words[$i]##*/}"
  if [[ "$cmd" == "git" ]]; then
    local j=$((i+1))
    while [[ $j -lt ${#words[@]} && "${words[$j]}" == -* ]]; do j=$((j+2)); done
    [[ $j -lt ${#words[@]} && "${words[$j]}" =~ ^($GIT_FILE_SUBCOMMANDS)$ ]] || return
  elif [[ ! "$cmd" =~ ^($FILE_COMMANDS)$ ]]; then
    return
  fi
  for word in "${words[@]:$((i+1))}"; do
    [[ "$word" == -* ]] && continue
    is_secret_name "$word" && refuse "$word"
  done
}

tool="$(json_get .tool_name)"

if [[ "$tool" == "Bash" ]]; then
  while IFS= read -r segment; do
    check_segment "$segment"
  done <<< "$(json_get .tool_input.command | strip_heredocs | sed -E 's/(&&|\|\||;|\|)/\n/g')"
  exit 0
fi

path="$(json_get .tool_input.file_path)"
[[ -z "$path" ]] && path="$(json_get .tool_input.notebook_path)"
if [[ -n "$path" ]] && is_secret_name "$path"; then
  deny "accès refusé à un fichier de secrets ($path). Utilise un fichier d'exemple (.env.example, .env.dist) ou demande à l'utilisateur."
fi
exit 0
