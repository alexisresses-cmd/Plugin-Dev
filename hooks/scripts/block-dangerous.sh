#!/usr/bin/env bash
# PreToolUse Bash : remplace les règles « deny » de l'ancien settings.json (un plugin ne peut pas en déclarer).
set -u
source "$(dirname "$0")/lib.sh"

command="$(json_get .tool_input.command)"
[[ -z "$command" ]] && exit 0

segments="$(printf '%s\n' "$command" | sed -E 's/(&&|\|\||;|\|)/\n/g')"

while IFS= read -r segment; do
  segment="$(printf '%s' "$segment" | sed -E 's/^[[:space:]]*(sudo[[:space:]]+)?//')"

  if [[ "$segment" =~ ^rm[[:space:]] ]] && [[ "$segment" =~ [[:space:]](-[a-zA-Z]*[rRf][a-zA-Z]*|--recursive|--force)([[:space:]]|$) ]]; then
    deny "« rm » récursif ou forcé interdit. Supprime les fichiers un par un sans -r/-f, ou demande à l'utilisateur."
  fi

  if [[ "$segment" =~ ^git[[:space:]]+(.*[[:space:]])?push([[:space:]]|$) ]]; then
    if [[ "$segment" =~ [[:space:]](--force|-f|--mirror)([[:space:]]|$) ]] || [[ "$segment" =~ [[:space:]]\+[^[:space:]]+ ]]; then
      deny "« git push --force » interdit. Utilise --force-with-lease sur ta branche de travail."
    fi
    if [[ "$segment" =~ --force-with-lease ]]; then
      # Sans refspec explicite (remote seul ou rien), c'est la branche courante qui est poussée.
      positional="$(printf '%s' "${segment#*push}" | tr -s '[:space:]' '\n' | grep -cv -e '^-' -e '^$')"
      current=""
      (( positional < 2 )) && current="$(git branch --show-current 2>/dev/null)"
      if [[ "$segment" =~ [[:space:]:](main|master)([[:space:]]|$) || "$current" =~ ^(main|master)$ ]]; then
        deny "réécriture de l'historique de la branche principale interdite."
      fi
    fi
  fi

  lower="$(printf '%s' "$segment" | tr '[:upper:]' '[:lower:]')"
  if [[ "$lower" =~ drop[[:space:]]+(database|schema)|doctrine:database:drop|doctrine:schema:drop|wp[[:space:]]+db[[:space:]]+(reset|drop|clean)|prisma[[:space:]]+migrate[[:space:]]+reset|migrate:fresh|schema:drop ]]; then
    deny "commande destructive sur une base de données refusée. Demande à l'utilisateur de la lancer lui-même."
  fi
  if [[ "$lower" =~ (^|[^a-z])(prod|production)([^a-z]|$) ]] && [[ "$lower" =~ (mysql|mariadb|psql|mongo|doctrine:|migrations:|wp[[:space:]]+db|prisma|typeorm|knex) ]]; then
    deny "commande de base de données visant la production refusée."
  fi
done <<< "$segments"
exit 0
