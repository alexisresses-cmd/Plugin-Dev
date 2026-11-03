---
profile: angular
extends: typescript
detect:
  files_any: [angular.json]
  composer_require_any: []
  package_json_any: ["@angular/core"]
---

# Profil angular

> Étend `typescript`. Angular ≥ 17 (composants standalone, signals, contrôle de flux `@if` / `@for`). Version lue dans `@angular/core` de `package.json` ; en dessous de 17, suivre les conventions observées (NgModules, `*ngFor`). AngularJS 1.x est hors périmètre.
> Les critères de review front (accessibilité, performance, RxJS) sont dans **Conventions**, lue par `reviewer-quality` et `dev-implement` ; les défauts de flux de données qui causent des bugs sont dans **Data & migrations**, lue par `reviewer-bugs`.

## Conventions
- Composants **standalone** (pas de nouveau `NgModule`) ; `imports` du composant limités à ce que le gabarit utilise.
- `changeDetection: ChangeDetectionStrategy.OnPush` sur tout nouveau composant.
- État local en **signals** (`signal`, `computed`, `effect` seulement pour un effet de bord hors du rendu) ; entrées et sorties en `input()`, `input.required()`, `output()`, `model()` si le projet est en Angular ≥ 17.1.
- Injection par **`inject()`** dans les nouveaux composants, services, guards et intercepteurs fonctionnels ; pas de mélange avec l'injection par constructeur dans une même classe.
- Gabarits avec `@if`, `@for`, `@switch` (pas de nouveau `*ngIf` / `*ngFor`) ; fichiers `*.component.ts|html|scss`, sélecteur préfixé (`app-`).
- Requêtes HTTP dans un **service** (`providedIn: 'root'`) qui retourne des `Observable` typés ; jamais d'appel `HttpClient` dans un composant.
- **Accessibilité** (critère de review) :
  - tout champ de formulaire a un `<label for>` associé (ou `aria-label` / `aria-labelledby` si pas de libellé visible) ; pas de libellé porté par le seul `placeholder` ;
  - contenu mis à jour dynamiquement (nombre de résultats, erreurs, « aucun résultat ») annoncé par une région `aria-live="polite"` (ou `role="status"`) présente dans le DOM avant la mise à jour ;
  - éléments interactifs natifs (`<button>`, `<a href>`) ; un `(click)` sur un `div` / `span` exige `role`, `tabindex="0"` et gestion de `Enter` / `Espace` ;
  - navigation clavier complète, ordre de tabulation logique, focus visible (pas de `outline: none` sans remplacement) ; focus déplacé vers le contenu ou le titre après une navigation ou l'ouverture d'un dialogue, rendu à l'élément d'origine à sa fermeture ;
  - contraste du texte ≥ 4.5:1 (3:1 pour le grand texte et les composants d'interface) ; information jamais portée par la seule couleur ; images informatives avec `alt`, décoratives avec `alt=""`.
- **Performance** (critère de review) :
  - composant `OnPush` ou piloté par signals ; pas de mutation d'un objet passé en entrée (nouvelle référence) ;
  - `@for` avec un `track` sur un identifiant stable (`track product.id`, pas `track $index` pour une liste qui change) ;
  - routes de fonctionnalité en **lazy loading** (`loadComponent` / `loadChildren`) ; `@defer` pour un bloc lourd hors du premier affichage ;
  - pas d'appel de méthode ni de calcul dans un gabarit (sauf lecture de signal) : `computed()` ou pipe pur ;
  - pas de nouvelle dépendance lourde sans justification (taille du bundle, budgets d'`angular.json` respectés).
- **RxJS** (critère de review) :
  - pas de `subscribe` imbriqué : opérateurs d'aplatissement (`switchMap` pour une recherche ou une navigation, `concatMap` pour des écritures ordonnées, `exhaustMap` pour un envoi de formulaire) ;
  - saisie utilisateur → requête : `debounceTime(…)`, `distinctUntilChanged()`, puis `switchMap` ;
  - désabonnement garanti : pipe `async`, `toSignal()`, ou `takeUntilDestroyed()` ; pas de `subscribe` sans l'un d'eux (sauf `HttpClient` à émission unique dans un service) ;
  - erreurs gérées dans le flux (`catchError` qui renvoie une valeur de repli) pour ne pas interrompre un flux long.

## Architecture
- Découpage par fonctionnalité (`src/app/products/`) : composants de page (routés, accès aux services) et composants de présentation (entrées / sorties, sans service).
- Routes dans `app.routes.ts` et `<feature>.routes.ts` ; fonctionnalités chargées en lazy loading.
- Configuration applicative dans `app.config.ts` (`provideRouter`, `provideHttpClient(withInterceptors([...]))`) ; intercepteurs et guards **fonctionnels**.
- Contrat d'API : interfaces TypeScript des réponses et requêtes dans un fichier dédié (`product.model.ts`), alignées sur l'API serveur (champs, types, nullabilité).
- État partagé entre composants : service avec signals (ou store existant du projet) ; pas d'état global ad hoc.
- Formulaires : **Reactive Forms** typés (`FormGroup<{…}>`, `nonNullable`) avec validateurs (`Validators.required`, `Validators.min(0)`) ; la validation client est une aide à la saisie, jamais une garantie.

## Testing
- Framework unitaire du projet : **Vitest** (`@analogjs/vitest-angular` ou builder expérimental) ou **Jest** (`jest-preset-angular`) ; Karma / Jasmine seulement s'il est déjà en place.
- Composants : `TestBed` avec `provideHttpClient()` + `provideHttpClientTesting()` (`HttpTestingController`) ou service doublé ; vérifier le DOM rendu (texte, attributs ARIA), pas l'état interne.
- Temporisation (`debounceTime`) : `vi.useFakeTimers()` / `jest.useFakeTimers()` ou `fakeAsync` + `tick(300)`.
- Parcours utilisateur : **Playwright** (`e2e/*.spec.ts`, sélecteurs `getByRole` / `getByLabel`), ou Cypress s'il est déjà en place ; API simulée (`page.route`) ou serveur de test.

## Security
- Pas de `[innerHTML]` sur une donnée non maîtrisée, pas d'`ElementRef.nativeElement.innerHTML`, jamais de `DomSanitizer.bypassSecurityTrust*` (`Html`, `Script`, `Style`, `Url`, `ResourceUrl`) sur une donnée externe ; l'interpolation `{{ }}` échappe par défaut.
- Aucun secret (clé d'API privée, mot de passe) dans le code front ou `environment*.ts` : tout est public une fois livré.
- Jetons d'authentification : cookie `HttpOnly` posé par le serveur de préférence ; si le projet stocke un jeton côté client (`localStorage`), le signaler (exposé au XSS), ne pas en ajouter un nouveau.
- Les **guards de route** (`canActivate`, `canMatch`) sont de l'ergonomie : chaque autorisation est vérifiée côté serveur.
- Jeton CSRF transmis via `HttpClientXsrfModule` / `withXsrfConfiguration` si l'API utilise des cookies de session.
- URL externes ou construites à partir d'une entrée : liste blanche de schémas (`https:`), jamais `javascript:`.

## Data & migrations
- Interfaces TypeScript d'API cohérentes avec le serveur : champ nullable côté serveur ⇒ `T | null` côté client ; gestion de l'état vide, du chargement et de l'erreur pour toute donnée asynchrone.
- Flux RxJS sources de bugs : `mergeMap` là où l'ordre ou l'annulation compte (réponses obsolètes affichées : utiliser `switchMap`), abonnement jamais libéré (fuite, appels en double à chaque navigation), `subscribe` imbriqué, erreur non interceptée qui termine un flux long.
- Pas de mutation directe d'un tableau ou d'un objet tenu dans un signal (`update(list => [...list, item])`).
- Pas de migration de données côté front ; un changement de format stocké côté client (`localStorage`) gère l'ancien format.

## Simplification
- `toSignal()` / pipe `async` plutôt qu'un `subscribe` qui recopie la valeur dans une propriété.
- `computed()` plutôt qu'un `effect()` qui écrit dans un autre signal.
- Supprimer un `NgModule` ou un `CommonModule` devenu inutile avec les composants standalone et le contrôle de flux.

## Tooling
- Build et budgets : `npx ng build` (budgets d'`angular.json`).
- Tests unitaires : `npx ng test` ou `npx vitest run` / `npx jest` selon le projet ; e2e : `npx playwright test` (ou `npx cypress run`).
- Lint : `npx ng lint` (`angular-eslint`) ; typage : `npx tsc --noEmit -p tsconfig.app.json`.
- Génération : `npx ng generate component <chemin>` (standalone par défaut à partir de la v17).
