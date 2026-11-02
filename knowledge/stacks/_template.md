---
profile: <nom-du-profil>       # kebab-case, identique au nom du fichier
extends: null                  # profil parent, ou null
detect:                        # utilisé par /devflow:init (une condition vraie suffit)
  files_any: []                # fichiers dont la présence identifie le profil
  composer_require_any: []     # paquets dans require / require-dev de composer.json
  package_json_any: []         # paquets dans dependencies / devDependencies de package.json
  headers_any: []              # facultatif : { file: <nom ou motif>, header: "<texte>" } cherché dans l'en-tête du fichier
---

# Profil <nom>

> Contrat (SPEC § 3.3) : les 7 sections ci-dessous sont **obligatoires**, avec ces titres exacts (vérifiés par la CI).
> Un profil enfant ne décrit que ses **différences** : écrire `_inherit_` seul dans une section pour reprendre celle du parent sans ajout.
> Pour annuler un point du parent, l'écrire explicitement : « **Remplace** : … ».
> Chaque point est une règle vérifiable, pas un conseil général. Pas d'exemples longs : un extrait de 3 lignes maximum.

## Conventions
<!-- Lu par : dev-implement, reviewer-quality, review-challenger, convention-detector -->

## Architecture
<!-- Lu par : architect, code-mapper, planners, dev-plan, dev-implement -->

## Testing
<!-- Lu par : test-writer, gate-checker -->

## Security
<!-- Lu par : security-analyst, reviewer-security -->

## Data & migrations
<!-- Lu par : planners, dev-plan, reviewer-bugs -->

## Simplification
<!-- Lu par : dev-simplifier -->

## Tooling
<!-- Lu par : gate-checker, /devflow:init -->
