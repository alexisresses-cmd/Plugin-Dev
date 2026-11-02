---
ticket: "#31"
title: Découper le gestionnaire AJAX d'inscription aux alertes
date: 2026-11-02
task_type: refactor
size: M
profiles: [wordpress]
security_audit: true
status: analysed
---

# Analyse — Découper le gestionnaire AJAX d'inscription aux alertes

## Ticket
Extraire `mt_ajax_subscribe` en fonctions séparées (validation, persistance, notification) dans `inc/subscribe.php`, sans changer le comportement.

## Vision code
### Fichiers impactés
| Fichier | Action | Raison |
|---|---|---|
| wp-content/themes/mon-theme/functions.php | modifier | `mt_ajax_subscribe` (l. 207-309) réduit à l'orchestration ; `require_once` de `inc/subscribe.php` ; le hook `wp_ajax_mt_subscribe` (l. 310) est conservé |
| wp-content/themes/mon-theme/inc/subscribe.php | créer | `mt_subscribe_validate_email`, `mt_subscribe_save`, `mt_subscribe_notify` (préfixe `mt_`, convention `inc/<sujet>.php`) |
### Points d'entrée
- Action AJAX `mt_subscribe` (`wp_ajax_` uniquement, pas de `nopriv`), appelée par `js/main.js` avec `nonce`, `email`, `event_type`.
- Contrôles existants en tête du gestionnaire : `check_ajax_referer( 'mt_subscribe', 'nonce' )`, `current_user_can( 'read' )` (403 sinon).
### Tests existants
Aucun test automatisé ; ni PHPUnit, ni Brain Monkey, ni `WP_UnitTestCase`.

## Vision architecture
### Comportement à préserver
- Codes et messages des réponses JSON : 403 (non connecté), 400 (e-mail invalide, domaine jetable), succès `exists` si déjà inscrit, 500 si l'insertion échoue, succès `created` avec `id`.
- Repli sur l'e-mail du compte quand `email` est vide ; `event_type` ignoré s'il n'existe pas dans la taxonomie.
- Deux e-mails : confirmation au membre, notification à `admin_email` ; journalisation si la confirmation échoue ; méta `mt_newsletter` ; action `mt_after_subscribe`.
### Recommandation
Fonctions extraites dans `inc/subscribe.php`, appelées dans le même ordre par `mt_ajax_subscribe`, qui garde le nonce, la capacité et les réponses `wp_send_json_*`.

## Vision sécurité
- **Requêtes concaténées** : `$wpdb->get_var` (l. 245) et `$wpdb->query` (l. 256) concatènent `$email` et `$event_type`. Les entrées passent par `sanitize_email` / `sanitize_key`, ce qui limite l'exploitation, mais ce n'est pas une protection reconnue : `$wpdb->prepare` est attendu (profil wordpress).
- Nonce et capacité présents et corrects.

## Synthèse
**Reformulation** : découper le gestionnaire AJAX en trois responsabilités, sans changement fonctionnel.
**Approche recommandée** : tests de caractérisation d'abord, puis extraction en petites étapes ; la requête concaténée est signalée (ticket séparé proposé) ; si elle est corrigée dans ce ticket, uniquement par `$wpdb->prepare` à résultat identique, justifié dans la PR.
**Risques prioritaires** : 1. changer un code de réponse ou un message ; 2. aucun filet de tests ; 3. perdre un effet de bord (méta, e-mail admin, action `mt_after_subscribe`).
**Questions bloquantes** : Aucune
**Feu vert** : ✅

<!-- PLAN — complété par /devflow:dev-plan -->
