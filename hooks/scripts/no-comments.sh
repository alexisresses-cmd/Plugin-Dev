#!/usr/bin/env bash
# PostToolUse Edit/Write : signale à Claude les commentaires ajoutés qui paraphrasent le code.
# Docblocks (/** */), directives d'outils et TODO rattachés à un ticket restent autorisés.
set -u
source "$(dirname "$0")/lib.sh"

path="$(json_get .tool_input.file_path)"
ext="${path##*.}"
case "$ext" in
  php|js|mjs|cjs|ts|tsx|jsx|vue|scss|css|less) ;;
  *) exit 0 ;;
esac

case "$(json_get .tool_name)" in
  Edit)
    added="$(diff <(json_get .tool_input.old_string) <(json_get .tool_input.new_string) | sed -n 's/^> //p')" ;;
  MultiEdit)
    added="$(json_get '[.tool_input.edits[].new_string] | join("\n")')" ;;
  *)
    if git ls-files --error-unmatch "$path" >/dev/null 2>&1; then
      added="$(git diff -U0 -- "$path" | sed -n '/^+++/d; s/^+//p')"
    else
      added="$(json_get .tool_input.content)"
    fi ;;
esac

hash_is_comment=1
[[ "$ext" =~ ^(scss|css|less|vue)$ ]] && hash_is_comment=0

allowed='phpcs:|phpstan-|psalm-|eslint-|prettier-ignore|@ts-|istanbul |c8 |noinspection|SPDX-|@codeCoverageIgnore|webpackChunkName|@license|(TODO|FIXME)[[:space:]:]*#?[A-Za-z]*-?[0-9]+'

offending="$(printf '%s\n' "$added" | while IFS= read -r line; do
  trimmed="$(printf '%s' "$line" | sed -E 's/^[[:space:]]+//')"
  [[ -z "$trimmed" ]] && continue
  is_comment=0
  [[ "$trimmed" == //*|| "$trimmed" == "<!--"* ]] && is_comment=1
  [[ "$trimmed" == /\** && "$trimmed" != /\*\** ]] && is_comment=1
  [[ $hash_is_comment -eq 1 && "$trimmed" == \#* && "$trimmed" != \#\[* && "$trimmed" != \#!* ]] && is_comment=1
  if [[ $is_comment -eq 1 ]] && ! [[ "$trimmed" =~ $allowed ]]; then
    printf '%s\n' "$trimmed"
  fi
done | head -5)"

[[ -z "$offending" ]] && exit 0

reason="Commentaires ajoutés dans $path :
$offending
Règle devflow : le code doit se suffire (nommage, extraction de méthode). Supprime ces commentaires, sauf s'ils expliquent un POURQUOI non déductible du code ; dans ce cas, garde-les et dis-le explicitement."
if command -v jq >/dev/null 2>&1; then
  jq -n --arg r "$reason" '{decision: "block", reason: $r}'
else
  python3 -c 'import json,sys; print(json.dumps({"decision": "block", "reason": sys.argv[1]}))' "$reason"
fi
exit 0
