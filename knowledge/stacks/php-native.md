# Profil php-native (provisoire)

> Version M1 : reprise telle quelle de `_shared/php-conventions.md` (v0).
> Réécrite au M3 selon le contrat des profils (`knowledge/stacks/_template.md`, 7 sections obligatoires).

## Standards

- **PSR-12** : style de code (indentation, accolades, espaces) — détaillé ci-dessous
- **PSR-4** : autoloading (namespace → chemin de fichier)
- **PSR-3** : interface de logging (`LoggerInterface`)

---

## PSR-12 — Style de code

### Fichier

```php
<?php
declare(strict_types=1);  // toujours en tête si typage strict activé
```

- Encoding UTF-8, pas de BOM
- Un seul `<?php` par fichier — pas de `?>` fermant
- Une ligne vide après `declare()`

### Indentation et longueur

- **4 espaces** — jamais de tabulations
- Longueur de ligne : **120 caractères max** (limite souple), 80 recommandés
- Une instruction par ligne

### Namespace et imports

```php
<?php
declare(strict_types=1);

namespace App\Service;

use App\Entity\User;
use App\Repository\UserRepository;
use Psr\Log\LoggerInterface;
```

- Une ligne vide après le bloc `namespace`
- Une ligne vide après le bloc `use`
- `use` triés par ordre alphabétique (recommandé)
- Pas de `use` inutilisés

### Classes

```php
class UserService extends AbstractService implements ServiceInterface
{
    // ouverture de l'accolade sur une nouvelle ligne
}
```

- `abstract`, `final` avant `class`
- `implements` peut être réparti sur plusieurs lignes si la liste est longue :

```php
class UserService extends AbstractService implements
    ServiceInterface,
    LoggerAwareInterface
{
}
```

### Constantes, propriétés, méthodes — ordre dans la classe

1. Constantes
2. Propriétés statiques
3. Propriétés d'instance
4. `__construct()`
5. Méthodes statiques
6. Méthodes d'instance (publiques → protégées → privées)

### Visibilité

```php
class Foo
{
    public string $name;        // toujours déclarer la visibilité
    private int $count = 0;

    public function getName(): string
    {
        return $this->name;
    }

    private function increment(): void
    {
        $this->count++;
    }
}
```

- Toujours déclarer `public`, `protected` ou `private` — jamais implicite
- `abstract` et `final` avant la visibilité : `abstract protected function foo()`
- `static` après la visibilité : `public static function bar()`

### Méthodes et fonctions

```php
public function process(int $id, string $name, bool $active = false): array
{
    // corps
}
```

- Accolade ouvrante sur une **nouvelle ligne**
- Pas d'espace entre le nom et la parenthèse ouvrante
- Espace après la virgule entre les arguments
- Type de retour obligatoire quand connu (`: string`, `: void`, `: ?User`)

Arguments sur plusieurs lignes si la liste est longue :

```php
public function create(
    string $name,
    string $email,
    ?int $roleId = null,
): User {
    // virgule finale recommandée sur le dernier argument
}
```

### Structures de contrôle

```php
// if / elseif / else
if ($condition) {
    // accolade sur la même ligne
} elseif ($other) {
    //
} else {
    //
}

// switch
switch ($value) {
    case 'foo':
        doSomething();
        break;
    default:
        doDefault();
}

// for / foreach / while
foreach ($items as $key => $value) {
    //
}

// Toujours des accolades, même pour un seul statement
// ❌ if ($x) doSomething();
// ✅ if ($x) { doSomething(); }
```

### Opérateurs

```php
$result = $a + $b;       // espaces autour des opérateurs binaires
$bool = !$flag;          // pas d'espace après opérateur unaire
$x = $a ?? $b;           // espaces autour de ??
$y = $a ?: $b;
```

### Closures et arrow functions

```php
$fn = function (int $x, int $y) use ($multiplier): int {
    return ($x + $y) * $multiplier;
};

$double = fn(int $x): int => $x * 2;
```

- Espace avant la parenthèse ouvrante de `function`
- Espace avant et après `use`

---

## Sécurité PHP — Checklist obligatoire

### Validation des entrées utilisateur

```php
// Toujours filtrer et valider les données externes
$id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
if ($id === false || $id === null) {
    // Entrée invalide
}
```

### Injection SQL

```php
// ❌ Jamais de concaténation directe
$query = "SELECT * FROM users WHERE id = " . $_GET['id'];

// ✅ Toujours des requêtes préparées
$stmt = $pdo->prepare("SELECT * FROM users WHERE id = :id");
$stmt->execute([':id' => $id]);
```

### XSS — Échappement à l'affichage

```php
// ❌ Dangereux
echo $_GET['name'];

// ✅ Toujours échapper
echo htmlspecialchars($_GET['name'], ENT_QUOTES, 'UTF-8');
```

### Upload de fichiers — Checklist

1. Vérifier `UPLOAD_ERR_OK` avant tout traitement
2. Valider le type MIME côté serveur via `mime_content_type()` — **pas l'extension**
3. Utiliser une liste **blanche** de types MIME acceptés (pas une liste noire)
4. Valider la taille contre une constante nommée
5. Renommer le fichier — jamais conserver le nom original
6. Déplacer avec `move_uploaded_file()` uniquement
7. Stocker hors webroot ou dans un dossier non exécutable

### CSRF

- Toujours vérifier un token CSRF sur les formulaires POST modifiant des données
- Ne jamais faire une action d'écriture via GET

### Sessions

- `session_regenerate_id(true)` après login/changement de privilège
- Timeout explicite configuré
- Données sensibles non stockées en clair en session

---

## Gestion des erreurs

```php
// Pattern standard — retourner les erreurs, ne pas les afficher directement
public function save(array $data): array
{
    $errors = [];

    if (empty($data['title'])) {
        $errors[] = 'Le titre est obligatoire.';
    }

    if (!empty($errors)) {
        return ['success' => false, 'errors' => $errors];
    }

    // ... traitement
    return ['success' => true];
}
```

- Distinguer erreurs utilisateur (mauvaise saisie) et erreurs système (BDD down)
- Erreurs utilisateur → affichage dans la vue
- Erreurs système → log (`error_log()` ou logger PSR-3), jamais affichées à l'utilisateur

---

## Typage PHP

Activer le typage strict en tête de fichier :

```php
<?php
declare(strict_types=1);
```

Typer les paramètres et retours de fonction :

```php
// ✅ Bon
public function findById(int $id): ?User
{
    // ...
}
```

---

## Autoloading PSR-4

Structure de namespace recommandée :

```
src/
  Controller/   → App\Controller\
  Service/      → App\Service\
  Repository/   → App\Repository\
  Entity/       → App\Entity\
  Exception/    → App\Exception\
```

---

## Conventions à surcharger dans CLAUDE.md

Le fichier `CLAUDE.md` du projet prend le dessus sur ces conventions génériques.
Si votre projet a des règles différentes (framework legacy, conventions d'équipe), documentez-les dans `CLAUDE.md` > section "Conventions spécifiques au projet".
