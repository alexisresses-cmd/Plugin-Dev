<?php require 'includes/header.php'; ?>
<?php
$lines = shop_cart_lines();
$total = shop_cart_total($lines);
if ($total >= 50) {
	$shipping = 0;
} else {
	$shipping = 4.90;
}
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $lines) {
	mysqli_query($db, "INSERT INTO orders (customer_email, total, shipping, created_at) VALUES ('" . $_POST['email'] . "', " . $total . ", " . $shipping . ", NOW())");
	$order_id = mysqli_insert_id($db);
	foreach ($lines as $line) {
		mysqli_query($db, "INSERT INTO order_lines (order_id, product_id, qty, price) VALUES (" . $order_id . ", " . $line['id'] . ", " . $line['qty'] . ", " . $line['price'] . ")");
	}
	$_SESSION['cart'] = array();
	echo '<p>Merci ! Commande n°' . $order_id . '</p>';
	require 'includes/footer.php';
	exit;
}
?>
<h1>Commande</h1>
<p>Total : <?php echo shop_format_price($total + $shipping); ?> (dont port <?php echo shop_format_price($shipping); ?>)</p>
<form method="post"><input type="email" name="email" required><button>Valider</button></form>
<?php require 'includes/footer.php'; ?>
