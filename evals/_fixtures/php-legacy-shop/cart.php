<?php require 'includes/header.php'; ?>
<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
	$_SESSION['cart'][$_POST['product_id']] = (int)$_POST['qty'];
}
$lines = shop_cart_lines();
$total = shop_cart_total($lines);
if ($total >= SHOP_FREE_SHIPPING_THRESHOLD) {
	$shipping = 0;
} else {
	$shipping = SHOP_SHIPPING_FEE;
}
?>
<h1>Panier</h1>
<table>
<?php foreach ($lines as $line) { ?>
	<tr><td><?php echo $line['name']; ?></td><td><?php echo $line['qty']; ?></td><td><?php echo shop_format_price($line['price'] * $line['qty']); ?></td></tr>
<?php } ?>
</table>
<p>Frais de port : <?php echo shop_format_price($shipping); ?></p>
<p>Total : <?php echo shop_format_price($total + $shipping); ?></p>
<a href="checkout.php">Commander</a>
<?php require 'includes/footer.php'; ?>
