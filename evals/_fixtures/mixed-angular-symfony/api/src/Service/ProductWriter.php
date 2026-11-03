<?php

declare(strict_types=1);

namespace App\Service;

use App\Dto\ProductInput;
use App\Entity\Product;
use Doctrine\ORM\EntityManagerInterface;

final readonly class ProductWriter
{
    public function __construct(private EntityManagerInterface $em)
    {
    }

    public function create(ProductInput $input): Product
    {
        $product = new Product($input->name, $input->priceInCents, $input->description);
        $this->em->persist($product);
        $this->em->flush();

        return $product;
    }

    public function update(Product $product, ProductInput $input): Product
    {
        $product->update($input->name, $input->priceInCents, $input->description);
        $this->em->flush();

        return $product;
    }
}
