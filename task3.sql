-- FILE: task3.sql
-- Internship Task 3: E-commerce sample DB + analysis queries
-- ---------------------------
-- 1) Create database and use it
DROP DATABASE IF EXISTS internship_task3;
CREATE DATABASE internship_task3;
USE internship_task3;

-- 2) Schema: customers, products, orders, order_items
CREATE TABLE customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_name VARCHAR(120),
  email VARCHAR(150),
  country VARCHAR(60)
);

CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  product_name VARCHAR(120),
  category VARCHAR(60),
  price DECIMAL(10,2)
);

CREATE TABLE orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  order_amount DECIMAL(10,2),
  status VARCHAR(30) DEFAULT 'Delivered',
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
  item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT,
  product_id INT,
  quantity INT,
  unit_price DECIMAL(10,2),
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 3) Insert sample data (small but realistic)
INSERT INTO customers (customer_name, email, country) VALUES
('John Doe','john@example.com','USA'),
('Asha B','asha@example.com','India'),
('Mark Z','mark@example.com','UK'),
('Shruthi J','shruthi@example.com','India'),
('Arun K','arun@example.com','India');

INSERT INTO products (product_name, category, price) VALUES
('Laptop Model A','Electronics', 600.00),
('Wireless Mouse','Accessories', 20.00),
('Travel Bag','Travel', 45.00),
('T-Shirt','Clothing', 399.00),
('Coffee Maker','Home', 2999.00);

-- Orders
INSERT INTO orders (customer_id, order_date, order_amount, status) VALUES
(1, '2025-02-01', 640.00, 'Delivered'),  -- John
(2, '2025-02-05', 135.00, 'Delivered'),  -- Asha
(1, '2025-02-10', 220.00, 'Cancelled'),  -- John (cancelled)
(3, '2025-02-11', 2999.00, 'Delivered'), -- Mark
(4, '2025-02-15', 399.00, 'Delivered');  -- Shruthi

-- Order items (link orders -> products)
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 600.00),  -- Laptop
(1, 2, 2, 20.00),   -- Mouse x2
(2, 3, 3, 45.00),   -- Bag x3
(3, 1, 1, 600.00),  -- Cancelled order item (will be excluded from some queries)
(4, 5, 1, 2999.00), -- Coffee Maker
(5, 4, 1, 399.00);  -- T-Shirt

-- 4) Analysis queries
-- A) Total Revenue (exclude cancelled orders)
SELECT
  SUM(oi.unit_price * oi.quantity) AS total_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status <> 'Cancelled';

-- B) Revenue per order (and customer)
SELECT
  o.order_id,
  o.order_date,
  c.customer_name,
  SUM(oi.unit_price * oi.quantity) AS order_revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status <> 'Cancelled'
GROUP BY o.order_id, o.order_date, c.customer_name
ORDER BY order_revenue DESC;

-- C) ARPU (average revenue per user) — only customers with >=1 non-cancelled order
SELECT AVG(user_rev) AS ARPU FROM (
  SELECT o.customer_id, SUM(oi.unit_price * oi.quantity) AS user_rev
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.status <> 'Cancelled'
  GROUP BY o.customer_id
) t;

-- D) Top selling products by revenue
SELECT p.product_id, p.product_name, SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status <> 'Cancelled'
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC
LIMIT 10;

-- E) Customers who have not placed any orders
SELECT c.customer_id, c.customer_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- F) Monthly revenue summary (VIEW + query)
CREATE OR REPLACE VIEW monthly_revenue AS
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month,
       SUM(oi.unit_price * oi.quantity) AS revenue,
       COUNT(DISTINCT o.customer_id) AS customers_count
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status <> 'Cancelled'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m');

SELECT * FROM monthly_revenue ORDER BY month;

-- G) Example index creation to optimize common joins
CREATE INDEX idx_orders_customer ON orders (customer_id);
CREATE INDEX idx_orderitems_product ON order_items (product_id);

-- H) Example EXPLAIN (run manually to inspect plan)
EXPLAIN SELECT p.product_name, SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status <> 'Cancelled'
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC;

-- End of file
