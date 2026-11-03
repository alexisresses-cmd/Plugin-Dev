<?php

declare(strict_types=1);

namespace App\Dto;

use App\Entity\Product;

/**
 * Contrat de lecture de /api/products et /api/admin/products.
 * Miroir TypeScript : front/src/app/products/product.ts (Product).
 */
final readonly class ProductOutput
{
    public function __construct(
        public int $id,
        public string $name,
        public int $priceInCents,
        public ?string $description,
    ) {
    }

    public static function fromEntity(Product $product): self
    {
        return new self(
            (int) $product->getId(),
            $product->getName(),
            $product->getPriceInCents(),
            $product->getDescription(),
        );
    }
}
