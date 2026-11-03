import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { ProductFormComponent } from './product-form.component';

describe('ProductFormComponent', () => {
  let http: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [ProductFormComponent],
      providers: [provideHttpClient(), provideHttpClientTesting(), provideRouter([])],
    });
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  it('n’envoie rien si le prix est négatif', () => {
    const fixture = TestBed.createComponent(ProductFormComponent);
    fixture.detectChanges();

    fixture.componentInstance.form.setValue({ name: 'Chaise', priceInCents: -1, description: null });
    fixture.componentInstance.submit();

    http.expectNone('/api/admin/products');
  });

  it('crée le produit avec le contrat ProductInput', () => {
    const fixture = TestBed.createComponent(ProductFormComponent);
    fixture.detectChanges();

    fixture.componentInstance.form.setValue({ name: 'Chaise', priceInCents: 4900, description: null });
    fixture.componentInstance.submit();

    const req = http.expectOne('/api/admin/products');
    expect(req.request.method).toBe('POST');
    expect(req.request.body).toEqual({ name: 'Chaise', priceInCents: 4900, description: null });
  });
});
