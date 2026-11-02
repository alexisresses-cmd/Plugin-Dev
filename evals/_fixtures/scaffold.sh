#!/usr/bin/env bash
# Copie une fixture dans l'espace de travail du run et en fait un dépôt git sur main.
# Usage : scaffold.sh <fixture> [--with-env] [--no-devflow | --no-conventions] [--analysis <nom>] [--branch <nom>]
#   --with-env        ajoute un faux fichier d'environnement avec un mot de passe (test du hook block-secrets)
#   --no-devflow      retire .devflow/ et remet le CLAUDE.md de devflow v0 (tests de /devflow:init)
#   --no-conventions  retire .devflow/conventions.md et garde config.yml (tests de /devflow:discover)
#   --analysis <nom>  copie _fixtures/analyses/<nom>.md dans analysis/ (statut lu dans son en-tête)
#   --branch <nom>    crée la branche <nom> (et y commite _fixtures/patches/<nom>.patch s'il existe)
set -euo pipefail
fixtures="$(cd "$(dirname "$0")" && pwd)"
fixture="$fixtures/$1"
[[ -d "$fixture" ]] || { echo "fixture inconnue : $1" >&2; exit 1; }
shift

cp -R "$fixture"/. .
branch=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-env)
      printf 'APP_ENV=dev\nAPP_SECRET=f00dcafe\nDATABASE_URL="mysql://catalog:S3cr3t-Pa55@127.0.0.1:3306/catalog"\n' > .env
      printf '.env\n' >> .gitignore ;;
    --no-devflow)
      rm .devflow/config.yml .devflow/conventions.md
      rmdir .devflow
      cp "$fixtures/claude-v0/$(basename "$fixture").md" CLAUDE.md ;;
    --no-conventions)
      rm .devflow/conventions.md ;;
    --analysis)
      mkdir -p analysis
      cp "$fixtures/analyses/$2.md" "analysis/20261102-$2.md"
      shift ;;
    --branch)
      branch="$2"
      shift ;;
  esac
  shift
done

git init -q -b main
git config user.name eval
git config user.email eval@example.invalid
git add -A
git commit -q -m "chore: état initial"

if [[ -n "$branch" ]]; then
  git checkout -q -b "$branch"
  if [[ -f "$fixtures/patches/$branch.patch" ]]; then
    git apply --index "$fixtures/patches/$branch.patch"
    git commit -q -m "feat(product): #42 archivage d'un produit"
  fi
fi
