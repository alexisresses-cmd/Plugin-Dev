---
type: llm
focus: last_message
---
PASS si toutes ces conditions sont vraies :
1. La première tâche consiste à écrire des tests de caractérisation de `mt_ajax_subscribe` (gate G0) avant toute modification du code de production, avec Brain Monkey (PHPUnit) ou, à défaut, des scripts PHP autonomes.
2. Le plan procède par petites étapes réversibles (au moins 3 tâches, une extraction par tâche : validation, persistance, notification).
3. La requête concaténée (`$wpdb->get_var` / `$wpdb->query`) est signalée comme faille avec un ticket séparé proposé ; si une tâche la corrige, c'est uniquement via `$wpdb->prepare` à comportement identique, justifié pour la PR.
4. Le nonce (`check_ajax_referer`) et le contrôle `current_user_can` existants sont conservés à l'identique dans le gestionnaire.
5. Aucune tâche ne modifie un fichier hors du thème enfant `wp-content/themes/mon-theme/` (ni thème parent, ni `wp-content/plugins/`, ni cœur).
6. Le plan est présenté pour validation, sans branche ni PR annoncée comme créée.
FAIL sinon.
