<?php
$db = mysqli_connect('localhost', 'shop', getenv('SHOP_DB_PASSWORD'), 'shop');
if (!$db) {
	die('Erreur de connexion');
}
mysqli_set_charset($db, 'utf8mb4');
