<?php require 'includes/header.php'; ?>
<h1>Catalogue</h1>
<ul>
<?php
$sql = "SELECT id, name, price FROM products";
if (isset($_GET['cat'])) {
	$sql .= " WHERE category_id = " . $_GET['cat'];
}
$res = mysqli_query($db, $sql);
while ($row = mysqli_fetch_assoc($res)) {
	echo '<li><a href="product.php?id=' . $row['id'] . '">' . $row['name'] . '</a> — ' . shop_format_price($row['price']) . '</li>';
}
?>
</ul>
<?php require 'includes/footer.php'; ?>
