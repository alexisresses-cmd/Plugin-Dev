<?php
require '../includes/header.php';
if (empty($_SESSION['is_admin'])) {
	header('Location: /index.php');
	exit;
}
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
	mysqli_query($db, "UPDATE products SET name = '" . $_POST['name'] . "', price = " . $_POST['price'] . ", description = '" . $_POST['description'] . "' WHERE id = " . $_POST['id']);
	echo '<p>Produit enregistré</p>';
}
$product = shop_get_product($_GET['id']);
?>
<h1>Modifier <?php echo $product['name']; ?></h1>
<form method="post">
	<input type="hidden" name="id" value="<?php echo $product['id']; ?>">
	<label>Nom <input name="name" value="<?php echo $product['name']; ?>"></label>
	<label>Prix <input name="price" value="<?php echo $product['price']; ?>"></label>
	<label>Description <textarea name="description"><?php echo $product['description']; ?></textarea></label>
	<button type="submit">Enregistrer</button>
</form>
<?php require '../includes/footer.php'; ?>
