<?php

declare(strict_types=1);

namespace App\Controller\Admin;

use App\Dto\ProductInput;
use App\Dto\ProductOutput;
use App\Entity\Product;
use App\Service\ProductWriter;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Attribute\MapRequestPayload;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\IsGranted;

#[Route('/api/admin/products')]
#[IsGranted('ROLE_ADMIN')]
final class ProductAdminController extends AbstractController
{
    #[Route('', methods: ['POST'])]
    public function create(#[MapRequestPayload] ProductInput $input, ProductWriter $writer): JsonResponse
    {
        return $this->json(ProductOutput::fromEntity($writer->create($input)), Response::HTTP_CREATED);
    }

    #[Route('/{id}', methods: ['PUT'])]
    public function update(Product $product, #[MapRequestPayload] ProductInput $input, ProductWriter $writer): JsonResponse
    {
        return $this->json(ProductOutput::fromEntity($writer->update($product, $input)));
    }
}
