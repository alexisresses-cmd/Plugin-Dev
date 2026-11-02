# ADR 0007 — dev-plan rédige le plan lui-même, seul le challenger est délégué

- **Statut :** accepté (validé par Alexis le 2026-11-02)
- **Date :** 2026-11-02
- **Réf. SPEC :** 3.5 (agents `planner-dev`, `planner-cto`), 3.6 (`dev-plan` : planners en parallèle) — **écart à la SPEC**

## Contexte

Mesure M2 sur le case `symfony-feature-01-plan` (2 runs chacun, même analyse en entrée) :

| Version | dev-plan | Coût / run | Qualité (grader `plan-quality`) |
|---|---|---|---|
| v0.1 | le skill planifie seul | 0,07 $ | plan complet ; seul le nom du mode diffère (« Orchestre ») |
| M2 initial | `planner-dev` ∥ `planner-cto` → `plan-challenger` | 0,68 $ | 2/2 |
| M2 retenu | le skill rédige le brouillon → `plan-challenger` | 0,38 $ | 2/2 |

L'analyse contient déjà la cartographie du code et l'architecture recommandée. Pour un ticket moyen, les planners refont ce travail sans gain de qualité mesurable.

## Décision

- `dev-plan` rédige le brouillon dans son contexte, puis le soumet à `devflow:plan-challenger` (opus) : le regard contradictoire est conservé.
- `planner-dev` et `planner-cto` restent disponibles et sont lancés en parallèle pour les tickets lourds (estimation Complexe ou plus de 8 fichiers). Ce seuil provisoire sera remplacé par le triage S/M/L au M3 (taille L).

## Conséquences

- Le plan coûte environ 5 fois plus qu'en v0.1, mais 44 % de moins que la version conforme à la SPEC. C'est le prix du challenge systématique.
- Le case `symfony-feature-01-plan` vérifie que les planners ne sont **pas** lancés pour un ticket moyen.
- Un case pour un ticket L sera ajouté au M3, avec le triage.
