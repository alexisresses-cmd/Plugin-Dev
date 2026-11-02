# RESOLVER — Chargement des règles (version M2)

> Procédure commune à tous les agents devflow. Chaque agent l'applique **avant sa mission**, pour la section qui le concerne (`<SECTION>`, indiquée dans son prompt).
> Version M2 : périmètre PHP uniquement, configuration lue dans `CLAUDE.md`. Au M3, cette procédure passera à `.devflow/config.yml` et aux profils / modes / types de tâche (SPEC § 3.2) ; les agents, eux, ne changeront pas.

## Étapes

1. **Projet** : lis le `CLAUDE.md` à la racine du projet, s'il existe. Retiens les conventions, l'architecture, les pièges connus et les points d'attention sécurité.
2. **Ticket** : si l'appelant fournit un fichier `analysis/*.md`, lis son en-tête (`task_type`, `security_audit`) et les sections utiles à ta mission. Ne relis pas ce que l'appelant t'a déjà transmis dans son message.
3. **Règles de stack** : dans `${CLAUDE_PLUGIN_ROOT}/knowledge/stacks/php-native.md`, lis **uniquement** les parties liées à ta section :

   | `<SECTION>` | Parties de `php-native.md` à lire |
   |---|---|
   | Conventions | Standards, PSR-12, Typage, Autoloading |
   | Architecture | Autoloading PSR-4, Gestion des erreurs |
   | Testing | (aucune ; voir l'agent) |
   | Security | Sécurité PHP — Checklist obligatoire |
   | Data & migrations | Injection SQL, Gestion des erreurs |
   | Simplification | Typage |
   | Tooling | Standards |

4. **Principes génériques** : lis `${CLAUDE_PLUGIN_ROOT}/knowledge/core/clean-code.md` seulement si ta section est `Conventions` ou `Simplification`.
5. **Priorité en cas de conflit** : `CLAUDE.md` du projet > `php-native.md` > `clean-code.md`. Les conventions observées dans le code existant priment sur les conventions idéales.

## Erreurs

- `CLAUDE.md` absent : continue en appliquant `php-native.md`, et signale-le dans ta sortie (`warnings`).
- Fichier d'analyse attendu mais absent : renvoie une erreur structurée à l'appelant, sans deviner son contenu :

  ```json
  { "error": "missing_input", "detail": "analysis file not found: <chemin>" }
  ```

## Règles communes à tous les agents

- Tu travailles seul : tu ne poses aucune question à l'utilisateur et tu ne lances aucun autre agent. S'il te manque une information, note-la dans ta sortie (`questions` ou `warnings`).
- Tu n'affirmes rien que tu n'as pas vérifié dans le code : cite les fichiers (et les lignes quand c'est utile).
- Tu respectes **exactement** le format de sortie de ton prompt : l'appelant l'analyse automatiquement.
