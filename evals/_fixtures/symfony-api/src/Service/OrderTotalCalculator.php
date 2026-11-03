<?php

declare(strict_types=1);

namespace App\Service;

final class OrderTotalCalculator
{
    /**
     * @param list<array{unitPrice: float, quantity: int}> $lines
     */
    public function total(array $lines, float $discountPercent = 0.0): float
    {
        $subtotal = 0.0;
        foreach ($lines as $line) {
            $subtotal += $line['unitPrice'] * $line['quantity'];
        }

        $discount = floor($subtotal * $discountPercent) / 100;

        return round($subtotal - $discount, 2);
    }
}
