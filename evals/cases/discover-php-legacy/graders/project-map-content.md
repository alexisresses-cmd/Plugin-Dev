---
type: llm
focus: { source: file, path: .devflow/project-map.md }
---
PASS si la carte du projet contient les 4 points suivants :
1. Points d'entrée : les pages PHP de la racine (`index.php`, `product.php`, `cart.php`, `checkout.php`) et le back-office `admin/` (`admin/product_edit.php`, `admin/order_edit.php`), éventuellement regroupés.
2. Risque : requêtes SQL construites par concaténation (au moins une parmi `checkout.php`, `admin/product_edit.php`, `admin/order_edit.php`, `includes/functions.php`), avec des entrées utilisateur.
3. Risque : calcul des frais de port dupliqué (au moins deux fichiers parmi `cart.php`, `checkout.php`, `admin/order_edit.php`, ou la valeur `4.90` codée en dur malgré `SHOP_SHIPPING_FEE`).
4. Aucun test automatisé, signalé comme risque ou par zone.
FAIL si l'un manque, ou si la carte recommande une refonte (framework, Composer, réécriture).
