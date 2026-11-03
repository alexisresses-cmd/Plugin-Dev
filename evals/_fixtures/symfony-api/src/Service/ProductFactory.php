<?php

declare(strict_types=1);

namespace App\Service;

use App\Entity\Category;
use App\Entity\Product;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException;
use Symfony\Component\Validator\Validator\ValidatorInterface;

final class ProductFactory
{
    public function __construct(
        private readonly EntityManagerInterface $entityManager,
        private readonly ValidatorInterface $validator,
    ) {
    }

    /**
     * @param array<string, mixed> $payload
     */
    public function createFromPayload(array $payload): Product
    {
        $category = $this->entityManager->find(Category::class, (int) ($payload['categoryId'] ?? 0));
        if ($category === null) {
            throw new UnprocessableEntityHttpException('Catégorie inconnue.');
        }

        $product = new Product((string) ($payload['name'] ?? ''), (int) ($payload['priceInCents'] ?? 0), $category);
        $violations = $this->validator->validate($product);
        if (count($violations) > 0) {
            throw new UnprocessableEntityHttpException((string) $violations);
        }

        $this->entityManager->persist($product);
        $this->entityManager->flush();

        return $product;
    }
}
