import { ChangeDetectionStrategy, Component, DestroyRef, OnInit, inject, input, signal } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { NonNullableFormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { ProductInput } from '../product';
import { ProductService } from '../product.service';

@Component({
  selector: 'app-product-form',
  imports: [ReactiveFormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './product-form.component.html',
})
export class ProductFormComponent implements OnInit {
  /** Identifiant lu dans la route (`admin/products/:id`), absent en création. */
  readonly id = input<string>();

  private readonly fb = inject(NonNullableFormBuilder);
  private readonly productService = inject(ProductService);
  private readonly router = inject(Router);
  private readonly destroyRef = inject(DestroyRef);

  readonly serverError = signal<string | null>(null);

  readonly form = this.fb.group({
    name: ['', [Validators.required, Validators.maxLength(120)]],
    priceInCents: [0, [Validators.required, Validators.min(0)]],
    description: this.fb.control<string | null>(null, Validators.maxLength(2000)),
  });

  ngOnInit(): void {
    const id = this.id();
    if (id) {
      this.productService
        .get(Number(id))
        .pipe(takeUntilDestroyed(this.destroyRef))
        .subscribe(({ name, priceInCents, description }) => this.form.setValue({ name, priceInCents, description }));
    }
  }

  submit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    const payload: ProductInput = this.form.getRawValue();
    const id = this.id();
    const request$ = id ? this.productService.update(Number(id), payload) : this.productService.create(payload);

    request$.pipe(takeUntilDestroyed(this.destroyRef)).subscribe({
      next: () => void this.router.navigate(['/products']),
      error: () => this.serverError.set("L'enregistrement a échoué."),
    });
  }
}
