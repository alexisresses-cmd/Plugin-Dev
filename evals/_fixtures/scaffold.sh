#!/usr/bin/env bash
# Copie une fixture dans l'espace de travail du run et en fait un dépôt git sur main.
# Usage : scaffold.sh <fixture> [--with-env]
set -euo pipefail
fixture="$(cd "$(dirname "$0")" && pwd)/$1"
[[ -d "$fixture" ]] || { echo "fixture inconnue : $1" >&2; exit 1; }

cp -R "$fixture"/. .
if [[ "${2:-}" == "--with-env" ]]; then
  printf 'APP_ENV=dev\nAPP_SECRET=f00dcafe\nDATABASE_URL="mysql://catalog:S3cr3t-Pa55@127.0.0.1:3306/catalog"\n' > .env
  printf '.env\n' > .gitignore
fi
git init -q -b main
git -c user.name=eval -c user.email=eval@example.invalid add -A
git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "chore: état initial"
