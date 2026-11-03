---
profile: wordpress
extends: php-native
detect:
  files_any: [wp-config.php, wp-load.php]
  composer_require_any: [johnpbloch/wordpress, roots/wordpress, wp-coding-standards/wpcs]
  package_json_any: []
  headers_any:                 # en-tête de commentaire dans les premières lignes du fichier
    - { file: style.css, header: "Theme Name:" }
    - { file: "*.php", header: "Plugin Name:" }
---

# Profil wordpress

> Étend `php-native`. Ne décrit que les différences propres à WordPress (≥ 6.0). Détection : `wp-config.php` ou `wp-load.php` présent, paquet Composer WordPress ou WPCS, `style.css` dont l'en-tête contient `Theme Name:`, ou fichier PHP à la racine du sous-projet dont l'en-tête contient `Plugin Name:`.
> Type de projet (`wordpress.type` dans `.devflow/config.yml`) : `theme`, `child-theme` (en-tête `Template:` dans `style.css`), `plugin`, `mu-plugin` (dossier `wp-content/mu-plugins/`), `site` (installation complète).
> Le JavaScript des blocs Gutenberg relève du profil `typescript` (jalon M5) : d'ici là, seule la partie PHP des blocs est couverte par ce profil.

## Conventions
- **Remplace** : PSR-12 → **WordPress Coding Standards** (WPCS) : indentation par tabulations, espaces à l'intérieur des parenthèses (`if ( $a )`), conditions Yoda (`if ( 'x' === $a )`), `snake_case` pour fonctions et variables, `Class_Name` pour les classes, fichiers `class-<nom>.php`.
- **Remplace** : PSR-4 obligatoire → préfixe unique (`mt_`, `MT_`) sur toute fonction, classe, constante, option, meta, hook et handle globaux, **ou** namespace PHP ; suivre ce que le projet utilise déjà.
- Le code s'accroche au cœur par des **hooks** : `add_action` / `add_filter` avec une priorité explicite si l'ordre compte (défaut 10) et le bon nombre d'arguments acceptés ; un filtre retourne toujours une valeur.
- Hooks propres au projet nommés avec le préfixe (`do_action( 'mt_after_subscribe', $id )`).
- Textes affichés traduisibles : `__()`, `esc_html__()`, `_e()` avec le text domain du thème ou de l'extension.
- Ressources front : `wp_enqueue_script` / `wp_enqueue_style` sur `wp_enqueue_scripts` ; jamais de `<script>` ou `<link>` écrit en dur dans un gabarit.

## Architecture
- **Jamais de modification du cœur** (`wp-admin/`, `wp-includes/`, fichiers racine) **ni d'une extension ou d'un thème tiers** : ils sont écrasés à la mise à jour. Personnaliser par hook, par thème enfant (surcharge de gabarit, `functions.php` enfant) ou par extension / mu-plugin dédié. Les chemins listés dans `wordpress.protected` sont refusés par le hook `protect-paths.sh`.
- Thème enfant : `style.css` avec `Template: <thème-parent>` ; surcharge d'un gabarit = copie dans le thème enfant ; `get_stylesheet_directory()` pour l'enfant, `get_template_directory()` pour le parent.
- Thème : présentation uniquement ; la logique métier durable (CPT, taxonomies, routes REST, traitements) qui doit survivre à un changement de thème va dans une extension ou un mu-plugin. En legacy, suivre l'emplacement observé et le signaler.
- `functions.php` long : le code nouveau va dans un fichier inclus (`inc/<sujet>.php`, `require_once get_stylesheet_directory() . '/inc/…'`) si le projet en a déjà, sinon dans `functions.php` en respectant le découpage existant.
- **CPT et taxonomies** : `register_post_type` / `register_taxonomy` sur `init`, avec `show_in_rest` si l'éditeur de blocs ou l'API les utilise ; slugs préfixés si le risque de collision existe.
- **ACF** : lecture par `get_field()` / `the_field()` en vérifiant que la fonction existe (`function_exists( 'get_field' )`) ; groupes de champs versionnés en JSON local (`acf-json/`) si le projet le fait déjà ; requêtes sur un champ ACF par `meta_query` sur la clé du champ.
- Requêtes de contenu : `WP_Query` / `get_posts` (avec `meta_query`, `tax_query`), jamais de SQL direct sur `wp_posts` quand l'API suffit.
- Points d'extension : shortcodes (`add_shortcode`, attributs via `shortcode_atts`), widgets, routes REST (`register_rest_route` sur `rest_api_init`), AJAX (`wp_ajax_<action>` et `wp_ajax_nopriv_<action>`), cron (`wp_schedule_event`), blocs (`register_block_type` + `block.json`).

## Testing
- Intégration : **`WP_UnitTestCase`** (suite de tests WordPress, `install-wp-tests.sh` ou **`wp-env`** : `npx wp-env run tests-cli --env-cwd=… vendor/bin/phpunit`).
- Unitaire sans WordPress : **Brain Monkey** (`Functions\when()`, `Functions\expect()`, `Actions\expectAdded()`) avec PHPUnit, pour tester une fonction qui appelle l'API WordPress sans base de données.
- Sans infrastructure de test : scripts PHP autonomes pour la logique pure (validation, formatage), plan de test manuel pour le reste (écran, rôle, nonce expiré, données ACF absentes).
- Emplacement : tests et scripts de test **dans le `path` du bloc** (ex. `wp-content/themes/mon-theme/tests/`), jamais à la racine de l'installation ni dans un dossier protégé.
- Plan de test manuel WordPress : préciser le rôle connecté (visiteur, abonné, éditeur, administrateur), la page ou l'écran d'administration, et vérifier la console et `debug.log` (`WP_DEBUG_LOG`).

## Security
- **Entrées** : `sanitize_text_field`, `sanitize_email`, `sanitize_key`, `absint`, `wp_unslash` avant nettoyage ; validation (`is_email`) distincte du nettoyage.
- **Sorties** : échappement **tardif**, au moment de l'affichage : `esc_html`, `esc_attr`, `esc_url`, `esc_js`, `esc_textarea` ; HTML autorisé via `wp_kses` / `wp_kses_post`. Jamais d'échappement à l'enregistrement en remplacement de l'échappement à l'affichage.
- **CSRF** : nonce sur tout formulaire, lien d'action et appel AJAX qui modifie des données (`wp_nonce_field` / `wp_create_nonce`, puis `check_admin_referer` / `check_ajax_referer` / `wp_verify_nonce`).
- **Autorisation** : `current_user_can( '<capacité>' )` (capacité, pas rôle) sur toute action sensible ; un nonce ne remplace pas un contrôle de capacité.
- **SQL** : `$wpdb->prepare()` avec `%d`, `%s`, `%f`, `%i` (identifiant, ≥ 6.2) sur toute requête qui contient une variable ; `$wpdb->esc_like()` pour un `LIKE`.
- **REST** : `permission_callback` obligatoire sur chaque route (`__return_true` uniquement pour une route publique assumée) ; `args` avec `sanitize_callback` / `validate_callback`.
- **AJAX** : `wp_ajax_nopriv_` seulement pour une action publique voulue ; nonce et capacité vérifiés dans le gestionnaire ; réponse par `wp_send_json_success` / `wp_send_json_error`.
- **Uploads** : `wp_handle_upload` / `media_handle_upload` avec `test_form` adapté ; types MIME limités (`mimes` en paramètre, filtre `upload_mimes`, `wp_check_filetype_and_ext`) ; jamais d'écriture directe dans `wp-content/uploads`.
- Redirections : `wp_safe_redirect` puis `exit`.
- Fichiers PHP d'un thème ou d'une extension : `defined( 'ABSPATH' ) || exit;` en tête des fichiers inclus.

## Data & migrations
- Accès direct : `$wpdb` avec `$wpdb->prefix` (jamais `wp_` en dur), toujours via `prepare` ; insertion / mise à jour via `$wpdb->insert` / `$wpdb->update` (formats explicites).
- Tables propres : `dbDelta()` (syntaxe stricte : deux espaces après `PRIMARY KEY`, une colonne par ligne) dans une routine d'installation déclenchée par une option de version (`mt_db_version`), pas à chaque chargement.
- Options : `get_option` / `update_option` préfixées ; `autoload` à `false` pour les options volumineuses. Cache temporaire : transients (`set_transient` avec expiration), invalidés quand la donnée change.
- Métadonnées : `get_post_meta` / `update_post_meta` (ou `get_field` ACF) plutôt qu'une table dédiée tant que les requêtes restent simples ; clés préfixées, clés privées commençant par `_`.
- Requêtes de liste : `posts_per_page` borné (jamais `-1` sur un contenu qui grandit), `no_found_rows` si pas de pagination, `meta_query` signalée comme coûteuse sur gros volumes.
- Changement de structure de données (CPT, meta, options) : migration idempotente et réversible, documentée dans la PR.

## Simplification
- Remplacer du SQL direct par l'API (`WP_Query`, `get_posts`, `get_post_meta`, `wp_insert_post`) quand elle couvre le besoin.
- Remplacer un nettoyage ou un échappement maison par la fonction WordPress dédiée.
- Supprimer un `global $post` quand la fonction reçoit déjà l'objet ou l'identifiant.
- Ne jamais déplacer ni renommer un hook, un préfixe ou une option existants : d'autres codes peuvent s'y accrocher.

## Tooling
- **Remplace** : `vendor/bin/phpcs` (standard PSR12) → `vendor/bin/phpcs --standard=WordPress` (ou `phpcs.xml.dist` du projet) ; correction : `vendor/bin/phpcbf --standard=WordPress`.
- Tests : `vendor/bin/phpunit` (Brain Monkey ou `WP_UnitTestCase`) ; `npx wp-env start` puis `npx wp-env run tests-cli …` pour la suite d'intégration.
- **WP-CLI** : `wp plugin list`, `wp theme list`, `wp option get`, `wp post list --post_type=<cpt>`, `wp eval-file` pour vérifier ou caractériser ; jamais `wp db reset|drop|clean` (bloqué par `block-dangerous.sh`).
- Analyse statique : PHPStan avec `szepeviktor/phpstan-wordpress` si installé.
- Version : `$wp_version` dans `wp-includes/version.php` ; en-têtes `Requires at least:` / `Requires PHP:` du thème ou de l'extension.
