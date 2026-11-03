# Conventions du projet

## Nommage
- Fonctions utilitaires globales en `snake_case` préfixées `shop_`, dans `includes/functions.php`.
- Indentation par tabulations.

## Architecture
- Pages PHP à la racine (front) et dans `admin/` (back-office) ; chaque page inclut `includes/header.php` et `includes/footer.php`.
- Connexion `mysqli` globale `$db` (`includes/db.php`).
- Pas de Composer, pas d'autoload, pas de namespaces.

## Données
- Schéma de référence : `sql/schema.sql` ; modifications par script SQL dans `sql/` (`YYYYMMDD-description.sql`).

## Tests
- Aucun test automatisé existant.
