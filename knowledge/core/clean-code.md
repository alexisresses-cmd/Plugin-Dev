# Référence — Clean Code & SOLID

> Version M1 : reprise de `_shared/clean-code.md` (v0). Les exemples PHP seront neutralisés au M3.

## Philosophie

Le code est lu bien plus souvent qu'il n'est écrit.
Un bon code ne nécessite pas de commentaire pour être compris.
La complexité accidentelle est l'ennemi principal.
Toujours préférer la solution la plus simple qui fonctionne correctement.

---

## Clean Code — Règles appliquées

### Nommage

- Un nom doit révéler l'intention — `$isImageValid` plutôt que `$check`
- Les fonctions sont des verbes — `validateImageType()`, `getUserById()`
- Les variables booléennes sont des questions — `$isActive`, `$hasError`, `$canEdit`
- Pas de noms génériques — éviter `$data`, `$result`, `$tmp` sauf portée d'une ligne
- Respecter les conventions de nommage définies dans `CLAUDE.md` du projet

### Fonctions

- Une fonction = une responsabilité — si tu dois écrire "et" pour décrire ce qu'elle fait, sépare-la
- Taille idéale : 10–20 lignes — au-delà, chercher à extraire
- Maximum 3 paramètres — au-delà, regrouper dans un objet / tableau associatif
- Pas d'effets de bord cachés — `getUser()` ne modifie pas la session
- Retourner tôt (early return) plutôt qu'imbriquer des if/else

```php
// ❌ Mauvais — imbrication profonde
function processUpload($file) {
    if ($file) {
        if ($this->isValidType($file)) {
            if ($this->isValidSize($file)) {
                return $this->save($file);
            }
        }
    }
    return false;
}

// ✅ Bon — early return
function processUpload($file) {
    if (!$file) return false;
    if (!$this->isValidType($file)) return false;
    if (!$this->isValidSize($file)) return false;
    return $this->save($file);
}
```

### Variables et état

- Déclarer au plus près de l'utilisation
- Éviter les variables globales sauf celles établies par le projet
- Éviter les flags booléens qui changent le comportement — préférer deux fonctions distinctes
- Immutabilité — ne pas réutiliser une variable pour des valeurs différentes

### Commentaires

- Le code doit se commenter lui-même — un bon nommage vaut mieux qu'un commentaire
- Commenter le POURQUOI, pas le QUOI
- Supprimer le code commenté — le contrôle de version est là pour ça
- Les TODO doivent avoir un contexte — ex: `// TODO #42 : gérer le cas multi-upload`

### Pas de nombres magiques

```php
// ❌ Mauvais
if ($fileSize > 10485760) { ... }

// ✅ Bon
const MAX_UPLOAD_SIZE_BYTES = 10 * 1024 * 1024; // 10 Mo
if ($fileSize > self::MAX_UPLOAD_SIZE_BYTES) { ... }
```

---

## Principes SOLID

### S — Single Responsibility Principle

Une classe, une raison de changer.

- Un contrôleur gère les requêtes HTTP — pas de logique métier complexe
- Un Repository gère les requêtes de persistance — pas de formatage d'affichage
- Une méthode de validation valide — elle ne sauvegarde pas

### O — Open/Closed Principle

Ouvert à l'extension, fermé à la modification.

- Préférer ajouter une méthode plutôt que modifier une existante avec un `if`
- Un `switch` sur un type qui grandit à chaque feature = violation de OCP

### L — Liskov Substitution Principle

Une sous-classe doit pouvoir remplacer sa parente sans casser le comportement.
Si tu étends une classe, les méthodes héritées doivent continuer à fonctionner comme attendu.

### I — Interface Segregation Principle

Mieux vaut plusieurs petites interfaces qu'une grande.
Ne pas forcer une classe à implémenter des méthodes dont elle n'a pas besoin.

### D — Dependency Inversion Principle

Dépendre des abstractions, pas des implémentations concrètes.
Injecter les dépendances plutôt que les instancier en dur dans les méthodes.

---

## DRY — Don't Repeat Yourself

Si le même bloc de code apparaît deux fois → extraire en méthode.
Si la même logique existe dans plusieurs fichiers → centraliser si réutilisable.

Attention : DRY s'applique à la logique, pas aux coïncidences. Deux blocs similaires qui évoluent indépendamment ne doivent pas être fusionnés.

---

## YAGNI — You Ain't Gonna Need It

Ne pas implémenter quelque chose parce que "ça pourra servir un jour".
Implémenter exactement ce que le ticket demande, rien de plus.

---

## Checklist avant de valider une tâche

- [ ] Le code fait exactement ce que la tâche demande
- [ ] Les noms révèlent l'intention
- [ ] Pas de duplication de logique
- [ ] Pas de nombre magique sans constante nommée
- [ ] Early return utilisé là où c'est plus lisible
- [ ] Pas de code commenté oublié
- [ ] Pas de `var_dump` / `dd()` / `print_r` de debug oublié
- [ ] Chaque fonction a une seule responsabilité
- [ ] Pas de scope creep silencieux
