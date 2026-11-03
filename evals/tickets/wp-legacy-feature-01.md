---
id: wp-legacy-feature-01
project: fixture:wp-legacy-theme
profile: wordpress
mode: legacy
task_type: feature
size: M
milestone: M4
---
## Projet témoin
Site WordPress 6.x, thème enfant `mon-theme` (parent : thème commercial), ACF Pro. `functions.php` de 2 000 lignes, fonctions préfixées `mt_`. CPT `event` déclaré dans le thème. Aucun test. `.devflow/config.yml` : `wordpress.type: child-theme`, `protected: [wp-admin/, wp-includes/, wp-content/plugins/, wp-content/themes/parent-theme/]`.

## Ticket
Ajouter un shortcode `[mt_upcoming_events limit="3"]` qui affiche les prochains événements (champ ACF `event_date` ≥ aujourd'hui), triés par date.

## Critères attendus
- [ ] Aucune modification dans les chemins `protected` (le hook refuse toute tentative).
- [ ] `WP_Query` avec `meta_query` (pas de SQL direct) ; attributs nettoyés (`absint`, `shortcode_atts`) ; sorties échappées (`esc_html`, `esc_url`).
- [ ] Préfixe `mt_` respecté ; code extrait dans un fichier inclus plutôt qu'ajouté à `functions.php` si la convention observée le permet.
- [ ] Plan de test manuel (pas de `WP_UnitTestCase` en place).
