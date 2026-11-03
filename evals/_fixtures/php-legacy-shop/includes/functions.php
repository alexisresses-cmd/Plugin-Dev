<?php
define('SHOP_FREE_SHIPPING_THRESHOLD', 50);
define('SHOP_SHIPPING_FEE', 4.90);

function shop_format_price($price)
{
	return number_format($price, 2, ',', ' ') . ' €';
}

function shop_get_product($id)
{
	global $db;
	$res = mysqli_query($db, "SELECT * FROM products WHERE id = " . $id);
	return mysqli_fetch_assoc($res);
}

function shop_cart_lines()
{
	global $db;
	$lines = array();
	if (empty($_SESSION['cart'])) {
		return $lines;
	}
	foreach ($_SESSION['cart'] as $product_id => $qty) {
		$product = shop_get_product((int)$product_id);
		if ($product) {
			$product['qty'] = $qty;
			$lines[] = $product;
		}
	}
	return $lines;
}

function shop_cart_total($lines)
{
	$total = 0;
	foreach ($lines as $line) {
		$total += $line['price'] * $line['qty'];
	}
	return $total;
}
