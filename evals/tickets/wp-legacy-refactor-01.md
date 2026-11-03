---
id: wp-legacy-refactor-01
project: fixture:wp-legacy-theme
profile: wordpress
mode: legacy
task_type: refactor
size: M
milestone: M4
---
## Projet témoin
Identique à `wp-legacy-feature-01`. Le gestionnaire AJAX `mt_ajax_subscribe` de `functions.php` (150 lignes) valide l'e-mail, écrit en base via `$wpdb->query` (requête concaténée) et envoie un mail.

## Ticket
Extraire `mt_ajax_subscribe` en fonctions séparées (validation, persistance, notification) dans `inc/subscribe.php`, sans changer le comportement.

## Critères attendus
- [ ] G0 : tests de caractérisation (Brain Monkey, ou scripts si absent) avant modification.
- [ ] Aucun fichier modifié dans `wp-content/plugins/` ni dans le thème parent.
- [ ] Requête concaténée **signalée** comme faille (ticket séparé proposé) ; si elle est corrigée, c'est uniquement via `$wpdb->prepare` à comportement identique et justifié dans la PR.
- [ ] Nonce et `current_user_can` existants conservés à l'identique.
- [ ] `reviewer-bugs` ne détecte aucun changement fonctionnel.
