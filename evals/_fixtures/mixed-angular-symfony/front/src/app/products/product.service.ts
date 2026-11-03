import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { Product, ProductInput } from './product';

@Injectable({ providedIn: 'root' })
export class ProductService {
  private readonly http = inject(HttpClient);

  list(): Observable<Product[]> {
    return this.http.get<Product[]>('/api/products');
  }

  get(id: number): Observable<Product> {
    return this.http.get<Product>(`/api/products/${id}`);
  }

  create(input: ProductInput): Observable<Product> {
    return this.http.post<Product>('/api/admin/products', input);
  }

  update(id: number, input: ProductInput): Observable<Product> {
    return this.http.put<Product>(`/api/admin/products/${id}`, input);
  }
}
