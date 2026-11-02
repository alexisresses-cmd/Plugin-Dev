---
type: regex
pattern: ">\\s*(50|SHOP_FREE_SHIPPING_THRESHOLD)\\b|strict"
target: { source: file, path: admin/order_edit.php }
---
