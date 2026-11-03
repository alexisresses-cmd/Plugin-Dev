import { ChangeDetectionStrategy, Component } from '@angular/core';
import { RouterLink, RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, RouterLink],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <nav aria-label="Navigation principale">
      <a routerLink="/products">Produits</a>
      <a routerLink="/admin/products/new">Nouveau produit</a>
    </nav>
    <main><router-outlet /></main>
  `,
})
export class AppComponent {}
