<?php

declare(strict_types=1);

namespace App\Tests\Controller\Admin;

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Symfony\Component\Security\Core\User\InMemoryUser;

final class ProductAdminControllerTest extends WebTestCase
{
    public function testCreateRequiresAdmin(): void
    {
        $client = static::createClient();
        $client->jsonRequest('POST', '/api/admin/products', ['name' => 'Chaise', 'priceInCents' => 4900]);

        self::assertResponseStatusCodeSame(401);
    }

    public function testCreateRejectsNegativePrice(): void
    {
        $client = static::createClient();
        $client->loginUser(new InMemoryUser('admin', null, ['ROLE_ADMIN']));
        $client->jsonRequest('POST', '/api/admin/products', ['name' => 'Chaise', 'priceInCents' => -1]);

        self::assertResponseStatusCodeSame(422);
    }
}
