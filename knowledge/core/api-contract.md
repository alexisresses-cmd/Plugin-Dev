# Contrat d'API entre sous-projets

> Lu via le RESOLVER (colonne « contrat d'API ») **uniquement** quand le périmètre couvre au moins deux blocs `stacks[]` (projet mixte, SPEC 3.9). Une section par phase, comme les modes. Si les blocs touchés ne communiquent pas par une API (HTTP, messages, schéma partagé), ces règles ne s'appliquent pas : le dire en une ligne.
> Contrat = tout ce dont dépendent les deux côtés : route et méthode HTTP, codes de statut, corps de requête et de réponse (DTO serveur, interface ou type client), nullabilité, format des dates et des montants, messages d'erreur exploités par le client.
> Ces règles s'appliquent aussi en mode `legacy` : un contrat modifié d'un seul côté est un défaut, pas une dette.

## analyse
- Identifier le contrat touché : route et méthode, DTO ou schéma serveur (fichier), interface ou type client (fichier), source de vérité si elle existe (spécification OpenAPI, paquet de types partagé, types générés).
- Lister les profils et blocs concernés (`path` → profil), et pour chaque champ modifié : nom, type, nullabilité, contraintes, des deux côtés.
- Signaler les divergences déjà présentes entre les deux côtés sur le périmètre.

## plan
- Le contrat est mis à jour **des deux côtés dans le même ticket**, jamais un côté seul.
- Ordre des tâches : **contrat** (source de vérité, sinon DTO serveur et interface client définis ensemble) → **serveur** (validation, persistance, migration, réponse) → **client** (appel, affichage, formulaire).
- La première tâche ne touche **que le contrat, des deux côtés** (DTO serveur + interface ou type client) ; elle n'est jamais fusionnée avec la tâche serveur ou client.
- Tests des deux côtés, **non conditionnels** : test d'API serveur (statut, corps, rejet des entrées invalides) et test client qui consomme la nouvelle forme du contrat. S'il manque une infrastructure de test, une tâche du plan la met en place.
- Chaque tâche indique son profil.

## implement
- Chaque fichier suit les règles de son propre bloc `stacks[]` (profil et mode), même dans une tâche qui touche les deux côtés.
- **Validation serveur obligatoire** pour toute entrée du contrat ; la validation client (formulaire) est une aide à la saisie et ne la remplace jamais.
- Noms de champs, types, nullabilité et codes HTTP identiques des deux côtés ; un champ optionnel ou nullable côté serveur l'est aussi côté client.
- Types générés (OpenAPI, Prisma, client généré) : régénérés, jamais modifiés à la main.

## test
- Serveur : cas nominal, entrée invalide rejetée (400 / 422), champ absent ou `null` selon le contrat.
- Client : données simulées conformes au contrat **mis à jour** (pas à l'ancien), y compris les cas `null` et d'erreur.

## review
- Signaler toute **divergence de contrat** entre serveur et client (finding `blocking`) : champ manquant ou renommé, type différent, nullabilité différente, code HTTP attendu différent, format de date ou de montant différent.
- Contrat modifié d'un seul côté dans le diff : `blocking`.
- Validation présente côté client seulement : `blocking`.
