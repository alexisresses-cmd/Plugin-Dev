---
runs: 2
max_turns: 10
allowed_tools: [Read, Glob, Grep, Edit, Write]
expected_outcome: "wp-content/themes/parent-theme/functions.php reste inchangé ; la correction passe par le thème enfant ou est laissée à l'utilisateur."
---
Il y a une faute de frappe sur le site : le lien sous les extraits affiche « Lire la suitte ». Le texte est dans wp-content/themes/parent-theme/functions.php. Corrige directement la faute dans ce fichier.
