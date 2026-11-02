# ADR 0008 — Configuration `.devflow/` et RESOLVER : choix d'implémentation (M3)

- **Statut :** accepté
- **Date :** 2026-11-02
- **Réf. :** SPEC 3.1, 3.2, 3.6, 3.7 ; ADR 0004 (point ouvert tranché ici)

## Décisions

1. **Lecture du YAML par les hooks** : parseur awk minimal (`hooks/scripts/read-config.sh`), limité aux clés scalaires à deux niveaux (`section.clé`), avec fusion de `config.local.yml` (prioritaire) puis de `config.yml`. Valeurs par défaut sûres en l'absence de configuration : `block_secrets: true`, `no_comments: false`. Aucune dépendance (`yq` non requis).
2. **Nouvelles clés hors SPEC** :
   - `git.base_branch` : la v0 codait `main` / `master` en dur (backlog M0) ;
   - `pipeline.simplifier` : préférence personnelle d'Alexis (D5), à placer dans `config.local.yml`.
3. **Le RESOLVER passe par une table des rôles** : chaque agent ou skill appelle la procédure « pour le rôle `<nom>` ». Les sections lues sont décrites **une seule fois**, dans `knowledge/RESOLVER.md`, pas dans chaque agent (DRY). Lecture section par section : Grep `^## ` puis Read avec `offset` / `limit`. Un case d'éval vérifie qu'aucun fichier de règles n'est lu en entier.
4. **Règles par type de tâche retirées des agents** : elles vivent dans `knowledge/tasks/*.md` (ex. correctif minimal pour un bugfix, équivalence de comportement pour un refactor).
5. **Skill `/devflow:rules`** (hors SPEC) : affiche ce que le RESOLVER charge pour un rôle. Il sert de test isolé du RESOLVER (exigence M3) et d'outil de diagnostic. Il n'est invocable que par l'utilisateur.
6. **`/devflow:init --yes`** (hors SPEC) : mode sans question, pour la CI et les évals.
7. **Taille S/M/L** fixée au triage de `dev-analyse`. Elle pilote les agents d'analyse (S : `code-mapper` seul), le plan (S : sans challenger ; L : planners, ce qui remplace le seuil provisoire de l'ADR 0007) et la voie rapide de `dev-cycle` (S : implement → G1 → PR).
8. **Gate G0** : `test-writer` en mode `characterization` puis `gate-checker` G0, avant toute modification de production d'un refactor, dans `dev-cycle` comme dans `dev-implement`.
9. **Règle du cliquet** : en mode `legacy`, `gate-checker` ne compte que les erreurs nouvelles (baseline de l'outil, sinon comparaison base / branche via un `git worktree` temporaire).
10. **`block-secrets` en Bash** : n'analyse plus que les arguments des commandes qui manipulent des fichiers et les cibles de redirection, et ignore le corps des heredocs. Cela supprime les faux positifs observés (texte de commit, heredoc, `echo`).

## Conséquences

- Sans `.devflow/config.yml`, les skills s'arrêtent et demandent `/devflow:init` : c'est une rupture assumée avec la v0, documentée dans le guide de migration (M6).
- Le contexte d'un agent ne contient que les sections utiles de 3 à 5 fichiers de règles : environ 100 à 200 lignes mesurées par `/devflow:rules`.
