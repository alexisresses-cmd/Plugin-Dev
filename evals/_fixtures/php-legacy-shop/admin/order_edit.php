<?php
require '../includes/header.php';
if (empty($_SESSION['is_admin'])) {
	header('Location: /index.php');
	exit;
}
$order = mysqli_fetch_assoc(mysqli_query($db, "SELECT * FROM orders WHERE id = " . (int)$_GET['id']));
$lines = array();
$res = mysqli_query($db, "SELECT ol.*, p.name FROM order_lines ol JOIN products p ON p.id = ol.product_id WHERE ol.order_id = " . (int)$order['id']);
while ($row = mysqli_fetch_assoc($res)) {
	$lines[] = $row;
}
$total = shop_cart_total($lines);
if ($total > 50) {
	$shipping = 0;
} else {
	$shipping = 4.90;
}
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
	mysqli_query($db, "UPDATE orders SET total = " . $total . ", shipping = " . $shipping . " WHERE id = " . (int)$order['id']);
	echo '<p>Commande recalculée</p>';
}
?>
<h1>Commande n°<?php echo $order['id']; ?></h1>
<p>Total : <?php echo shop_format_price($total + $shipping); ?> (port <?php echo shop_format_price($shipping); ?>)</p>
<form method="post"><button>Recalculer</button></form>
<?php require '../includes/footer.php'; ?>
