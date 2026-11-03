<?php

declare(strict_types=1);

namespace App\Controller;

use App\Entity\Product;
use App\Repository\ProductRepository;
use App\Service\ProductFactory;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\IsGranted;

#[Route('/api/products')]
final class ProductController extends AbstractController
{
    #[Route('', methods: ['GET'])]
    public function list(ProductRepository $products): JsonResponse
    {
        return $this->json($products->findCatalog(), context: ['groups' => 'product:read']);
    }

    #[Route('/{id}', methods: ['GET'])]
    public function show(Product $product): JsonResponse
    {
        return $this->json($product, context: ['groups' => 'product:read']);
    }

    #[Route('', methods: ['POST'])]
    #[IsGranted('PRODUCT_CREATE')]
    public function create(Request $request, ProductFactory $factory): JsonResponse
    {
        $product = $factory->createFromPayload($request->toArray());

        return $this->json($product, Response::HTTP_CREATED, context: ['groups' => 'product:read']);
    }
}
