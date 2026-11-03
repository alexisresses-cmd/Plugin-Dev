#!/usr/bin/env bash
# Tests des hooks devflow : chaque cas envoie une entrée JSON et vérifie la décision.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPTS="$ROOT/hooks/scripts"
pass=0; fail=0

expect() {
  local verdict="$1" script="$2" label="$3" input="$4" out code actual
  out="$(printf '%s' "$input" | "$SCRIPTS/$script" 2>&1)"; code=$?
  if [[ $code -eq 2 || "$out" == *'"decision": "block"'* || "$out" == *'"decision":"block"'* ]]; then actual=block; else actual=allow; fi
  if [[ "$actual" == "$verdict" ]]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL [$script] $label → $actual (attendu $verdict)"; [[ -n "$out" ]] && echo "     $out"; fi
}

bash_in() { jq -n --arg c "$1" '{tool_name:"Bash",tool_input:{command:$c}}'; }
file_in() { jq -n --arg t "$1" --arg p "$2" '{tool_name:$t,tool_input:{file_path:$p}}'; }
edit_in() { jq -n --arg p "$1" --arg o "$2" --arg n "$3" '{tool_name:"Edit",tool_input:{file_path:$p,old_string:$o,new_string:$n}}'; }
write_in() { jq -n --arg p "$1" --arg c "$2" '{tool_name:"Write",tool_input:{file_path:$p,content:$c}}'; }

# block-secrets
expect block block-secrets.sh "Read .env"              "$(file_in Read /app/.env)"
expect block block-secrets.sh "Read .env.local"        "$(file_in Read /app/.env.local)"
expect block block-secrets.sh "Edit .env.prod"         "$(file_in Edit /app/.env.prod)"
expect block block-secrets.sh "Write wp-config.php"    "$(file_in Write /site/wp-config.php)"
expect block block-secrets.sh "Read parameters.yml"    "$(file_in Read app/config/parameters.yml)"
expect block block-secrets.sh "Read cert.pem"          "$(file_in Read /etc/ssl/cert.pem)"
expect block block-secrets.sh "Read private.key"       "$(file_in Read keys/private.key)"
expect allow block-secrets.sh "Read .env.example"      "$(file_in Read /app/.env.example)"
expect allow block-secrets.sh "Read .env.dist"         "$(file_in Read /app/.env.dist)"
expect allow block-secrets.sh "Read src/Env.php"       "$(file_in Read /app/src/Env.php)"
expect allow block-secrets.sh "Read keyboard.ts"       "$(file_in Read /app/src/keyboard.ts)"
expect block block-secrets.sh "cat .env"               "$(bash_in 'cat .env')"
expect block block-secrets.sh "git add .env.local"     "$(bash_in 'git add src/ .env.local')"
expect block block-secrets.sh "grep in wp-config"      "$(bash_in "grep DB_ ./wp-config.php")"
expect block block-secrets.sh "source .env"            "$(bash_in 'source ./.env && php bin/console')"
expect allow block-secrets.sh "cp .env.example"        "$(bash_in 'cat .env.example')"
expect allow block-secrets.sh "git status"             "$(bash_in 'git status --short')"
expect allow block-secrets.sh "phpunit"                "$(bash_in 'vendor/bin/phpunit --filter KeyService')"

# block-dangerous
expect block block-dangerous.sh "rm -rf"               "$(bash_in 'rm -rf var/cache')"
expect block block-dangerous.sh "rm -fr"               "$(bash_in 'rm -fr build')"
expect block block-dangerous.sh "rm -f"                "$(bash_in 'rm -f file.txt')"
expect block block-dangerous.sh "rm -r chained"        "$(bash_in 'cd /tmp && rm -r foo')"
expect block block-dangerous.sh "sudo rm -Rf"          "$(bash_in 'sudo rm -Rf /var/www')"
expect allow block-dangerous.sh "rm simple"            "$(bash_in 'rm tests/test_Foo.php')"
expect block block-dangerous.sh "push --force"         "$(bash_in 'git push --force')"
expect block block-dangerous.sh "push -f"              "$(bash_in 'git push -f origin feat/42')"
expect block block-dangerous.sh "push +refspec"        "$(bash_in 'git push origin +feat/42')"
expect block block-dangerous.sh "lease on main"        "$(bash_in 'git push --force-with-lease origin main')"
expect allow block-dangerous.sh "lease on feature"     "$(bash_in 'git push --force-with-lease origin feat/42-upload')"
expect allow block-dangerous.sh "push -u"              "$(bash_in 'git push -u origin feat/42-upload')"
expect block block-dangerous.sh "doctrine drop"        "$(bash_in 'php bin/console doctrine:database:drop --force')"
expect block block-dangerous.sh "wp db reset"          "$(bash_in 'wp db reset --yes')"
expect block block-dangerous.sh "prisma reset"         "$(bash_in 'npx prisma migrate reset')"
expect block block-dangerous.sh "DROP DATABASE"        "$(bash_in 'mysql -e "DROP DATABASE shop"')"
expect block block-dangerous.sh "migrations prod"      "$(bash_in 'APP_ENV=prod php bin/console doctrine:migrations:migrate')"
expect block block-dangerous.sh "mysql prod host"      "$(bash_in 'mysql -h db.prod.internal shop')"
expect allow block-dangerous.sh "migrations dev"       "$(bash_in 'php bin/console doctrine:migrations:migrate -n')"
expect allow block-dangerous.sh "build --prod"         "$(bash_in 'npm run build -- --configuration production')"

# no-comments
expect block no-comments.sh "php // ajouté"            "$(edit_in src/A.php '$a = 1;' $'// incrémente a\n$a = 2;')"
expect block no-comments.sh "php # ajouté"             "$(edit_in src/A.php '$a = 1;' $'# set a\n$a = 2;')"
expect block no-comments.sh "ts /* */"                 "$(edit_in src/a.ts 'x()' $'/* call x */\nx()')"
expect allow no-comments.sh "php docblock"             "$(edit_in src/A.php 'f();' $'/**\n * @return int\n */\nf();')"
expect allow no-comments.sh "php attribute #["         "$(edit_in src/A.php 'f();' $'#[Route(\'/a\')]\nf();')"
expect allow no-comments.sh "ts @ts-expect-error"      "$(edit_in src/a.ts 'x()' $'// @ts-expect-error legacy lib\nx()')"
expect allow no-comments.sh "TODO ticket"              "$(edit_in src/A.php 'f();' $'// TODO #42 : gérer le multi-upload\nf();')"
expect allow no-comments.sh "phpcs ignore"             "$(edit_in src/A.php 'f();' $'// phpcs:ignore Generic.Files\nf();')"
expect allow no-comments.sh "commentaire existant"     "$(edit_in src/A.php $'// existant\n$a = 1;' $'// existant\n$a = 2;')"
expect allow no-comments.sh "scss #id"                 "$(edit_in src/a.scss '.a{}' $'#main { color: red; }')"
expect allow no-comments.sh "markdown ignoré"          "$(edit_in README.md 'a' $'// pas du code')"
expect block no-comments.sh "write nouveau fichier"    "$(write_in /tmp/devflow-new-$$.ts $'// utilitaire\nexport const a = 1;')"
expect allow no-comments.sh "write propre"             "$(write_in /tmp/devflow-new-$$.ts $'export const a = 1;')"

# restrict-agents
agent_in() { jq -n --arg a "$1" --arg c "$2" '{tool_name:"Bash",agent_type:$a,tool_input:{command:$c}}'; }
expect allow restrict-agents.sh "reviewer git diff"      "$(agent_in devflow:reviewer-bugs 'git diff main...HEAD')"
expect allow restrict-agents.sh "reviewer git log | head" "$(agent_in devflow:reviewer-quality 'git log main..HEAD --oneline | head -20')"
expect allow restrict-agents.sh "challenger git show"     "$(agent_in devflow:review-challenger 'git show HEAD:src/A.php')"
expect allow restrict-agents.sh "reviewer git -C"         "$(agent_in devflow:reviewer-security 'git -C /app grep -n query')"
expect block restrict-agents.sh "reviewer git commit"     "$(agent_in devflow:reviewer-bugs 'git commit -am fix')"
expect block restrict-agents.sh "reviewer git checkout"   "$(agent_in devflow:reviewer-bugs 'git checkout -- src/A.php')"
expect block restrict-agents.sh "reviewer sed -i"         "$(agent_in devflow:reviewer-quality 'sed -i s/a/b/ src/A.php')"
expect block restrict-agents.sh "reviewer chained rm"     "$(agent_in devflow:reviewer-quality 'git diff && touch x')"
expect block restrict-agents.sh "reviewer diff --output"  "$(agent_in devflow:reviewer-bugs 'git diff --output=/tmp/x')"
expect block restrict-agents.sh "reviewer pipe xargs"     "$(agent_in devflow:reviewer-bugs 'git log --format=%H | xargs rm')"
expect block restrict-agents.sh "reviewer redirection"    "$(agent_in devflow:reviewer-bugs 'git diff > /tmp/x')"
expect block restrict-agents.sh "reviewer subshell"       "$(agent_in devflow:reviewer-bugs 'git log $(touch x)')"
expect allow restrict-agents.sh "reviewer 2>/dev/null"    "$(agent_in devflow:reviewer-bugs 'git diff main...HEAD 2>/dev/null || git diff master...HEAD 2>&1')"
expect allow restrict-agents.sh "gate-checker phpunit"    "$(agent_in devflow:gate-checker 'vendor/bin/phpunit')"
expect allow restrict-agents.sh "session principale"      "$(bash_in 'git commit -m x')"

echo "hooks : $pass OK, $fail KO"
exit $fail
