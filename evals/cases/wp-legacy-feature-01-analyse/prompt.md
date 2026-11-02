---
runs: 1
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Agent, Write]
expected_outcome: "Analyse WordPress legacy : WP_Query + meta_query sur event_date, shortcode_atts/absint, esc_html/esc_url, préfixe mt_, aucune modification hors du thème enfant, plan de test manuel."
---
/devflow:dev-analyse Ajouter un shortcode `[mt_upcoming_events limit="3"]` qui affiche les prochains événements (champ ACF `event_date` ≥ aujourd'hui), triés par date.
