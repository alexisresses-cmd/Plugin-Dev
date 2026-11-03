import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { ProductListComponent } from './product-list.component';

describe('ProductListComponent', () => {
  let http: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [ProductListComponent],
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  it('affiche les produits renvoyés par l’API', () => {
    const fixture = TestBed.createComponent(ProductListComponent);
    fixture.detectChanges();

    http.expectOne('/api/products').flush([
      { id: 1, name: 'Chaise', priceInCents: 4900, category: 'Mobilier' },
      { id: 2, name: 'Lampe', priceInCents: 2500, category: 'Luminaire' },
    ]);
    fixture.detectChanges();

    const items = fixture.nativeElement.querySelectorAll('li');
    expect(items.length).toBe(2);
    expect(items[0].textContent).toContain('Chaise');
  });
});
