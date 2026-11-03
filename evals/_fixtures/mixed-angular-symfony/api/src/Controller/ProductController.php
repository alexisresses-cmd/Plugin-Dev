<?php

declare(strict_types=1);

namespace App\Controller;

use App\Dto\ProductOutput;
use App\Entity\Product;
use App\Repository\ProductRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/api/products')]
final class ProductController extends AbstractController
{
    #[Route('', methods: ['GET'])]
    public function list(ProductRepository $products): JsonResponse
    {
        return $this->json(array_map(ProductOutput::fromEntity(...), $products->findAllOrdered()));
    }

    #[Route('/{id}', methods: ['GET'])]
    public function show(Product $product): JsonResponse
    {
        return $this->json(ProductOutput::fromEntity($product));
    }
}
