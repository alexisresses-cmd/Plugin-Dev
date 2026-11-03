#!/usr/bin/env bash
# Test négatif de scripts/validate.sh : une copie du dépôt est cassée, chaque erreur doit être signalée.
set -uo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'find "$tmp" -delete' EXIT

tar -C "$repo" --exclude=.git --exclude=_source --exclude=node_modules --exclude=.claude -cf - . | tar -C "$tmp" -xf -

ok=0; ko=0
check() { # check <libellé> <motif attendu dans la sortie>
  if grep -qF -- "$2" <<<"$out"; then ok=$((ok + 1)); echo "OK  $1"; else ko=$((ko + 1)); echo "KO  $1 (attendu : $2)"; fi
}

# Copie intacte : doit passer.
out="$("$repo/scripts/validate.sh" --root "$tmp" 2>&1)" && rc=0 || rc=$?
[ "$rc" -eq 0 ] && check "copie intacte" "validate : OK" || { ko=$((ko + 1)); echo "KO  copie intacte : $out"; }

# Casse : JSON, YAML, profil, cycle, agent, référence, rôle.
echo '{ "a": ' > "$tmp/hooks/hooks.json"
printf 'name: "x\n' > "$tmp/templates/config.yml"
sed -i '/^## Security$/d' "$tmp/knowledge/stacks/symfony.md"
sed -i 's/^extends: null$/extends: symfony/' "$tmp/knowledge/stacks/php-native.md"
sed -i 's/^name: code-mapper$/name: mapper/' "$tmp/agents/code-mapper.md"
sed -i '/^## gates$/d' "$tmp/knowledge/tasks/bugfix.md"
echo 'Voir devflow:agent-fantome.' >> "$tmp/commands/init.md"
sed -i 's/^| `gate-checker` |/| `gate-fantome` |/' "$tmp/knowledge/RESOLVER.md"

out="$("$repo/scripts/validate.sh" --root "$tmp" 2>&1)" && rc=0 || rc=$?
[ "$rc" -ne 0 ] && { ok=$((ok + 1)); echo "OK  code de sortie non nul"; } || { ko=$((ko + 1)); echo "KO  code de sortie nul"; }
check "JSON invalide" "hooks/hooks.json : JSON invalide"
check "YAML invalide" "templates/config.yml : YAML invalide"
check "section de profil" "knowledge/stacks/symfony.md : section « ## Security » absente"
check "cycle extends" "cycle d'héritage"
check "nom d'agent" "agents/code-mapper.md : name « mapper »"
check "section de tâche" "knowledge/tasks/bugfix.md : section « ## gates » absente"
check "référence devflow" "devflow:agent-fantome ne correspond"
check "table des rôles" "rôle « gate-fantome »"

echo "$ok OK, $ko KO"
[ "$ko" -eq 0 ]
