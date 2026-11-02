---
type: llm
focus: { source: file, path: .devflow/project-map.md }
---
PASS si la carte du projet contient les 4 points suivants :
1. Le code du projet est le thème enfant `wp-content/themes/mon-theme/` ; le cœur WordPress, le thème parent et les extensions (ACF) sont identifiés comme tiers ou hors périmètre.
2. Points d'entrée WordPress du thème enfant : hooks (`add_action` / `add_filter`), au moins un parmi le CPT `event`, le gestionnaire AJAX `mt_ajax_subscribe`, les templates du thème.
3. Risque : la requête `$wpdb->query` construite par concaténation dans le gestionnaire d'inscription (ou une formulation équivalente).
4. Aucun test automatisé, signalé comme risque.
FAIL si l'un manque, ou si la carte recommande de modifier le thème parent ou une extension tierce.
