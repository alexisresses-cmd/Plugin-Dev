# Référence — Scripts de test PHP sans framework

## Principe

Pas de PHPUnit. Des scripts PHP simples, exécutables en CLI, qui incluent
la classe à tester et vérifient les résultats avec des assertions manuelles.

## Structure d'un fichier de test

```php
<?php
// tests/test_ImageValidator.php

declare(strict_types=1);

require_once __DIR__ . '/../src/Validator/ImageValidator.php';

$passed = 0;
$failed = 0;

function assert_true(string $label, bool $result): void {
    global $passed, $failed;
    if ($result) {
        echo "[OK]   " . $label . PHP_EOL;
        $passed++;
    } else {
        echo "[FAIL] " . $label . PHP_EOL;
        $failed++;
    }
}

function assert_equals(string $label, mixed $expected, mixed $actual): void {
    assert_true($label . " (attendu: " . json_encode($expected) . ", obtenu: " . json_encode($actual) . ")", $expected === $actual);
}

function assert_contains(string $label, mixed $needle, array $haystack): void {
    assert_true($label, in_array($needle, $haystack, true));
}

// --- TESTS ---

// Happy path
$validator = new ImageValidator(['size' => 1024, 'error' => UPLOAD_ERR_OK, 'tmp_name' => '/tmp/test.jpg']);
assert_true('Fichier valide accepté', $validator->isValid());

// Cas limite — taille zéro
$validator = new ImageValidator(['size' => 0, 'error' => UPLOAD_ERR_OK, 'tmp_name' => '/tmp/test.jpg']);
assert_true('Fichier vide refusé', !$validator->isValid());

// Cas limite — trop lourd
$validator = new ImageValidator(['size' => 20 * 1024 * 1024, 'error' => UPLOAD_ERR_OK, 'tmp_name' => '/tmp/test.jpg']);
assert_true('Fichier trop lourd refusé', !$validator->isValid());

// Cas d'erreur — upload échoué
$validator = new ImageValidator(['size' => 1024, 'error' => UPLOAD_ERR_PARTIAL, 'tmp_name' => '']);
assert_true('Upload partiel refusé', !$validator->isValid());

// --- BILAN ---
echo PHP_EOL . "Résultats : {$passed} OK, {$failed} FAIL" . PHP_EOL;
exit($failed > 0 ? 1 : 0);
```

## Lancer les tests

```bash
# Un seul fichier
php tests/test_ImageValidator.php

# Tous les fichiers
for f in tests/test_*.php; do php "$f"; done

# Avec résumé global
failed=0
for f in tests/test_*.php; do
  php "$f" || failed=$((failed+1))
done
echo "Suites échouées : $failed"
exit $failed
```

## Ce qui est testable par script

- Classes instanciables sans dépendances BDD ni session
- Méthodes statiques utilitaires (formatage, calcul, transformation)
- Logique métier pure sans appel à `$pdo->query()`, `$_SESSION`, `$_FILES`
- Validators, Formatters, Helpers, DTOs

## Ce qui nécessite un test manuel

- Méthodes avec requêtes SQL directes
- Méthodes qui lisent `$_POST`, `$_GET`, `$_FILES`, `$_SESSION`
- Rendu des templates / vues
- Appels `header()` ou `exit()`
- Comportements dépendant du contexte HTTP
- Interactions avec des services externes (API, email, S3…)

## Nommage des fichiers

Convention : `tests/test_{NomClasse}.php`

```
tests/
  test_ImageValidator.php
  test_ArticleFormatter.php
  test_PriceCalculator.php
```

## Bonnes pratiques

- Utiliser des données fictives explicites (`'Mon titre de test'`, `42`, etc.)
- Tester un seul comportement par assertion
- Le label de l'assertion = description du comportement attendu
- `exit(1)` si au moins un test échoue — utile pour CI futur
- Ne jamais dépendre d'une BDD réelle dans les scripts
- Adapter le `require_once` au chemin réel de la classe dans le projet
