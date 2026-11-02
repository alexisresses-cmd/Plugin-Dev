# Conventions du projet

## Nommage
- Fonctions, options, métas et hooks du thème préfixés `mt_` (`snake_case`), sans namespace ni classe.
- Indentation par tabulations, style WordPress (espaces dans les parenthèses).
- Text domain : `mon-theme`.

## Architecture
- Seul le thème enfant `wp-content/themes/mon-theme/` est maintenu par l'équipe. Le thème parent (commercial), ACF Pro et le cœur WordPress ne sont jamais modifiés.
- `functions.php` regroupe hooks, CPT, shortcodes et AJAX ; les fonctions d'affichage sont dans `inc/template-tags.php`. Un nouveau sujet va dans un nouveau fichier `inc/<sujet>.php` inclus par `require_once` depuis `functions.php`.
- Champs ACF lus par `get_field()` (champ `event_date` au format `Ymd`, `event_place`).

## Données
- Table propre `{$wpdb->prefix}mt_subscribers` créée par `dbDelta` (option `mt_db_version`).

## Tests
- Aucun test automatisé, ni PHPUnit ni Brain Monkey. Vérification manuelle sur l'environnement de recette.
