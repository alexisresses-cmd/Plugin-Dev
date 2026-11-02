<?php require 'includes/header.php'; ?>
<?php
$product = shop_get_product($_GET['id']);
if (!$product) {
	echo '<p>Produit introuvable</p>';
	require 'includes/footer.php';
	exit;
}
?>
<h1><?php echo $product['name']; ?></h1>
<p class="price"><?php echo shop_format_price($product['price']); ?></p>
<p><?php echo nl2br($product['description']); ?></p>
<form method="post" action="cart.php">
	<input type="hidden" name="product_id" value="<?php echo $product['id']; ?>">
	<input type="number" name="qty" value="1" min="1">
	<button type="submit">Ajouter au panier</button>
</form>
<?php require 'includes/footer.php'; ?>
