<?php

declare(strict_types=1);

namespace App\Entity;

use App\Repository\ProductRepository;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: ProductRepository::class)]
class Product
{
    #[ORM\Id, ORM\GeneratedValue, ORM\Column]
    private ?int $id = null;

    #[ORM\Column(length: 120)]
    private string $name;

    #[ORM\Column]
    private int $priceInCents;

    #[ORM\Column(length: 2000, nullable: true)]
    private ?string $description = null;

    public function __construct(string $name, int $priceInCents, ?string $description = null)
    {
        $this->name = $name;
        $this->priceInCents = $priceInCents;
        $this->description = $description;
    }

    public function update(string $name, int $priceInCents, ?string $description): void
    {
        $this->name = $name;
        $this->priceInCents = $priceInCents;
        $this->description = $description;
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function getPriceInCents(): int
    {
        return $this->priceInCents;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }
}
