---
type: llm
focus: last_message
---
PASS si le rapport final respecte l'approche WordPress legacy, c'est-à-dire au moins 5 de ces 6 points :
1. Les événements sont lus par `WP_Query` (ou `get_posts`) avec une `meta_query` sur `event_date` (comparaison à la date du jour au format `Ymd`) et un tri sur cette méta, sans SQL direct.
2. Les attributs du shortcode passent par `shortcode_atts` et `limit` est converti par `absint` (ou borné équivalent).
3. Les sorties sont échappées (`esc_html` pour les textes, `esc_url` pour les liens).
4. Le code suit les conventions observées : préfixe `mt_`, style WordPress, ajout dans un fichier `inc/` inclus depuis `functions.php` (ou dans `functions.php` avec justification).
5. Aucune modification n'est prévue hors du thème enfant `wp-content/themes/mon-theme/` (ni thème parent, ni ACF, ni cœur).
6. Un plan de test manuel est prévu (aucune infrastructure de test en place), ou des tests Brain Monkey proposés comme option.
FAIL si l'analyse prévoit de modifier le thème parent, une extension ou le cœur, ou recommande une requête SQL directe sur `wp_posts` / `wp_postmeta`.
