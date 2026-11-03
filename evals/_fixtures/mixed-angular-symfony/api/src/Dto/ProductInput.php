<?php

declare(strict_types=1);

namespace App\Dto;

use Symfony\Component\Validator\Constraints as Assert;

/**
 * Contrat d'écriture de POST et PUT /api/admin/products.
 * Miroir TypeScript : front/src/app/products/product.ts (ProductInput).
 */
final readonly class ProductInput
{
    public function __construct(
        #[Assert\NotBlank]
        #[Assert\Length(max: 120)]
        public string $name = '',

        #[Assert\PositiveOrZero]
        public int $priceInCents = 0,

        #[Assert\Length(max: 2000)]
        public ?string $description = null,
    ) {
    }
}
