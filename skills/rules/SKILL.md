---
name: rules
description: >
  Affiche les règles que devflow charge pour un rôle (agent ou skill) sur un fichier ou un ticket :
  profils, chaîne d'héritage, mode, type de tâche, sections lues et règles qui s'appliquent.
  Sert à vérifier la configuration et à comprendre une décision d'un agent.
argument-hint: "<rôle> [fichier…] [analysis/xxx.md]"
disable-model-invocation: true
---

# rules — Règles chargées par le RESOLVER

Arguments : `$ARGUMENTS`
- `<rôle>` : un rôle de la table de `${CLAUDE_PLUGIN_ROOT}/knowledge/RESOLVER.md` (ex. `reviewer-quality`, `test-writer`, `gate-checker`). Sans rôle, affiche la table des rôles et arrête-toi.
- fichiers : le périmètre (sinon, le diff de la branche avec `git.base_branch`).
- `analysis/*.md` : le ticket (sinon `task_type: feature`).

## Procédure

Applique **exactement** `${CLAUDE_PLUGIN_ROOT}/knowledge/RESOLVER.md` pour ce rôle, en respectant la consigne de lecture section par section. Ne lis rien d'autre.

## Sortie

```
🔎 RÈGLES — rôle {rôle}
Configuration : .devflow/config.yml {+ config.local.yml}
Type de tâche : {task_type} (source : {fichier d'analyse | défaut})

Fichier → profil (mode)
  {fichier} → {profil} ({mode}) via path « {path} »

Fichiers lus (dans l'ordre de priorité)
  1. .devflow/conventions.md            {lu | absent}
  2. tasks/{type}.md      § {section}
  3. modes/{mode}.md      § {section}
  4. stacks/{enfant}.md   § {sections}   {« _inherit_ » le cas échéant}
     stacks/{parent}.md   § {sections}
  5. core/clean-code.md                 {lu | non requis}

Règles déterminantes (5 maximum par source, une ligne chacune, avec la source)
  [task] …
  [mode] …
  [stack:{profil}] …

Conflits arbitrés
  {règle A} vs {règle B} → {retenue} (priorité {source})
```

Termine par le nombre approximatif de lignes lues dans `knowledge/`, pour vérifier l'économie de tokens.
