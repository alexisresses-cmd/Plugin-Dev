/**
 * Contrat d'API produit, miroir des DTO PHP :
 * - Product      ↔ api/src/Dto/ProductOutput.php
 * - ProductInput ↔ api/src/Dto/ProductInput.php
 */
export interface Product {
  id: number;
  name: string;
  priceInCents: number;
  description: string | null;
}

export type ProductInput = Omit<Product, 'id'>;
