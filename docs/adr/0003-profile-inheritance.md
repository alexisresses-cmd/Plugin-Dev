# ADR 0003 — Héritage des profils de stack

- **Statut :** accepté
- **Date :** 2026-11-02
- **Réf. SPEC :** D3, 3.2, 3.3

## Contexte

Symfony et WordPress partagent l'essentiel des règles PHP. NestJS, Node et Angular partagent celles de TypeScript. Dupliquer ces règles crée des divergences.

## Décision

Chaque profil déclare `extends` dans son en-tête YAML :

```
php-native ─┬─ symfony
            └─ wordpress        (WPCS remplace PSR-12)
typescript ─┬─ node ── nestjs
            └─ angular
```

- Un profil enfant ne décrit que **ses différences**.
- Les 7 sections sont obligatoires : `Conventions`, `Architecture`, `Testing`, `Security`, `Data & migrations`, `Simplification`, `Tooling`. Dans un enfant, une section peut valoir `_inherit_` (reprise du parent sans ajout).
- Résolution : l'agent remonte la chaîne `extends` et lit **uniquement sa section**, du parent vers l'enfant ; l'enfant complète ou remplace le parent sur un point explicitement nommé.
- La CI (M6) vérifie : sections présentes, chaînes `extends` existantes et sans cycle.
- Laravel et AngularJS 1.x sont hors périmètre v1.

## Conséquences

- Ajouter une stack = un fichier + un ticket de référence (D6). Guide : `docs/adding-a-stack.md` (M6).
- La règle « l'enfant remplace » doit être explicite dans le texte (ex. « WPCS remplace PSR-12 ») pour qu'un agent ne cumule pas deux standards contradictoires.
