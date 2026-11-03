# Tickets de référence

> Principe D6 : on mesure avant d'élargir. Chaque profil, mode et type de tâche est couvert par au moins un ticket de référence, et aucun nouveau profil n'est ajouté sans ticket associé.

## Structure

```
evals/
├── tickets/<id>.md            # un ticket de référence
└── results/YYYYMMDD-vX.Y.md   # un rapport d'exécution par version
```

> Le passage au format natif `claude plugin eval` est proposé dans `docs/backlog.md` (ADR 0006). Il sera décidé avant le M1.

## Format d'un ticket

```markdown
---
id: wp-legacy-refactor-01
project: <chemin, URL ou fixture>
profile: wordpress
mode: legacy
task_type: refactor
size: M            # S | M | L
milestone: M4      # jalon à partir duquel le ticket doit passer
---
## Ticket
<texte du ticket, tel qu'un développeur le recevrait>

## Critères attendus
- [ ] critère vérifiable
```

## Projets témoins

Pour l'instant, les projets sont **fictifs** : chaque ticket décrit dans `project` une fixture à générer (`fixture:<nom>`), avec son état de départ dans la section `## Projet témoin`. Ils seront remplacés par de vrais projets, ou générés par script, au moment de la première exécution (M1).

| Fixture | Profil(s) | Mode |
|---|---|---|
| `php-legacy-shop` | php-native | legacy |
| `symfony-api` | symfony | modern |
| `wp-legacy-theme` | wordpress | legacy |
| `nest-greenfield` | nestjs | greenfield |
| `angular-app` | angular | modern |
| `mixed-angular-symfony` | angular (`front/`) + symfony (`api/`) | modern |

## Couverture

| Ticket | Profil | Mode | Type | Taille | Jalon |
|---|---|---|---|---|---|
| `symfony-modern-feature-01` | symfony | modern | feature | M | M1 |
| `symfony-modern-bugfix-01` | symfony | modern | bugfix | M | M1 |
| `php-legacy-feature-01` | php-native | legacy | feature | M | M3 |
| `php-legacy-refactor-01` | php-native | legacy | refactor | M | M3 |
| `symfony-modern-fastlane-01` | symfony | modern | bugfix | **S** | M3 |
| `wp-legacy-feature-01` | wordpress | legacy | feature | M | M4 |
| `wp-legacy-refactor-01` | wordpress | legacy | refactor | M | M4 |
| `nest-greenfield-feature-01` | nestjs | greenfield | feature | M | M5 |
| `angular-modern-feature-01` | angular | modern | feature | M | M5 |
| `mixed-modern-feature-01` | angular + symfony | modern | feature | L | M5 |

## Rapport d'exécution

`results/YYYYMMDD-vX.Y.md`, avec pour chaque ticket : critères OK / KO, tokens consommés, gates passées au premier essai, findings jugés invalides par `review-challenger`, retouches manuelles.

## Critères communs à tous les tickets

Sauf mention contraire, chaque ticket vérifie aussi :
- [ ] Fichier `analysis/YYYYMMDD-{slug}.md` créé avec `task_type`, `size`, `profiles` corrects.
- [ ] Tous les commits passent par `dev-commit` et respectent `git.commit_format`.
- [ ] Aucun fichier modifié hors du périmètre du plan.
- [ ] Aucun secret lu ni écrit (`.env*`, `*.pem`, `*.key`…).
