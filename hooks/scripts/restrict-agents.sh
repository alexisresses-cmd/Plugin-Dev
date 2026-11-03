#!/usr/bin/env bash
# PreToolUse Bash : les agents devflow en lecture seule ne peuvent lancer que des commandes git de lecture.
# Le champ « tools » d'un agent ne sait pas restreindre Bash par commande (ADR 0001, point 2).
set -u
source "$(dirname "$0")/lib.sh"

agent="$(json_get .agent_type)"
case "$agent" in
  devflow:reviewer-*|devflow:review-challenger) ;;
  *) exit 0 ;;
esac

command="$(json_get .tool_input.command)"
read_only_git='^git[[:space:]]+(-C[[:space:]]+[^[:space:]]+[[:space:]]+)?(diff|log|show|status|blame|grep|ls-files|rev-parse|merge-base|branch[[:space:]]+--show-current|symbolic-ref)([[:space:]]|$)'

read_only_filter='^(head|tail|grep|wc|sort|uniq|cut|cat|nl)([[:space:]]|$)'

while IFS= read -r segment; do
  segment="$(printf '%s' "$segment" | sed -E 's/2>(&1|\/dev\/null)//g; s/^[[:space:]]+//; s/[[:space:]]+$//')"
  [[ -z "$segment" ]] && continue
  if [[ "$segment" =~ (^|[[:space:]])(--output|-o)([=[:space:]]|$) || "$segment" =~ [\>\<\`]|\$\( ]] \
     || ! [[ "$segment" =~ $read_only_git || "$segment" =~ $read_only_filter ]]; then
    deny "l'agent $agent est en lecture seule : seules les commandes git de lecture sont autorisées (refusé : $segment)."
  fi
done <<< "$(printf '%s\n' "$command" | sed -E 's/(&&|\|\||;|\|)/\n/g')"
exit 0
