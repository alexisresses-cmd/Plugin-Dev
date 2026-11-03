import { CurrencyPipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { RouterLink } from '@angular/router';
import { ProductService } from './product.service';

@Component({
  selector: 'app-product-list',
  imports: [CurrencyPipe, RouterLink],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <h1>Produits</h1>
    <ul>
      @for (product of products(); track product.id) {
        <li>
          <a [routerLink]="['/admin/products', product.id]">{{ product.name }}</a>
          <span class="price">{{ product.priceInCents / 100 | currency: 'EUR' }}</span>
        </li>
      }
    </ul>
  `,
})
export class ProductListComponent {
  readonly products = toSignal(inject(ProductService).list(), { initialValue: [] });
}
