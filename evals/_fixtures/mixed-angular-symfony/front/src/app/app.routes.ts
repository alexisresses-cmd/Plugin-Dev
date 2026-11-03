import { Routes } from '@angular/router';

export const routes: Routes = [
  { path: '', pathMatch: 'full', redirectTo: 'products' },
  { path: 'products', loadComponent: () => import('./products/product-list.component').then((m) => m.ProductListComponent) },
  { path: 'admin/products/new', loadComponent: () => import('./products/admin/product-form.component').then((m) => m.ProductFormComponent) },
  { path: 'admin/products/:id', loadComponent: () => import('./products/admin/product-form.component').then((m) => m.ProductFormComponent) },
];
