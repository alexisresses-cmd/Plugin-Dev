<?php

declare(strict_types=1);

namespace App\Tests\Service;

use App\Service\OrderTotalCalculator;
use PHPUnit\Framework\TestCase;

final class OrderTotalCalculatorTest extends TestCase
{
    public function testTotalWithoutDiscount(): void
    {
        $total = (new OrderTotalCalculator())->total([['unitPrice' => 10.0, 'quantity' => 2]]);

        self::assertSame(20.0, $total);
    }
}
