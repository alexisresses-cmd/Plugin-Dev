#!/usr/bin/env bash
# PreToolUse : empêche de lire, écrire ou manipuler en shell les fichiers de secrets.
set -u
source "$(dirname "$0")/lib.sh"

ALLOWED_ENV_SUFFIX='example|dist|sample|template|test'

is_secret_name() {
  local name="${1##*/}"
  case "$name" in
    .env|.env.local|wp-config.php|parameters.yml|id_rsa|id_ed25519|*.pem|*.key|*.p12|*.pfx) return 0 ;;
    .env.*) [[ ! "$name" =~ ^\.env\.($ALLOWED_ENV_SUFFIX)$ ]] && return 0 ;;
  esac
  return 1
}

tool="$(json_get .tool_name)"

if [[ "$tool" == "Bash" ]]; then
  command="$(json_get .tool_input.command)"
  for word in $(printf '%s' "$command" | tr -s "'\"=;|&()<> \t" '\n'); do
    if is_secret_name "$word"; then
      deny "commande refusée : elle vise un fichier de secrets ($word). Demande à l'utilisateur de le faire lui-même si c'est nécessaire."
    fi
  done
  exit 0
fi

path="$(json_get .tool_input.file_path)"
[[ -z "$path" ]] && path="$(json_get .tool_input.notebook_path)"
if [[ -n "$path" ]] && is_secret_name "$path"; then
  deny "accès refusé à un fichier de secrets ($path). Utilise un fichier d'exemple (.env.example, .env.dist) ou demande à l'utilisateur."
fi
exit 0
