import { expect, test } from '@playwright/test';

test('la liste des produits s’affiche', async ({ page }) => {
  await page.route('/api/products', (route) =>
    route.fulfill({ json: [{ id: 1, name: 'Chaise', priceInCents: 4900, category: 'Mobilier' }] }),
  );

  await page.goto('/products');

  await expect(page.getByRole('heading', { name: 'Catalogue' })).toBeVisible();
  await expect(page.getByRole('listitem')).toHaveCount(1);
});
