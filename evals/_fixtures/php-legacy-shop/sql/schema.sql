CREATE TABLE products (id INT AUTO_INCREMENT PRIMARY KEY, category_id INT, name VARCHAR(255) NOT NULL, price DECIMAL(10,2) NOT NULL, description TEXT);
CREATE TABLE orders (id INT AUTO_INCREMENT PRIMARY KEY, customer_email VARCHAR(255), total DECIMAL(10,2), shipping DECIMAL(10,2), created_at DATETIME);
CREATE TABLE order_lines (id INT AUTO_INCREMENT PRIMARY KEY, order_id INT, product_id INT, qty INT, price DECIMAL(10,2));
