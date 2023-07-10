DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
	customer_id VARCHAR (50) NOT NULL PRIMARY KEY,
	customer_unique_id VARCHAR (50),
	customer_zip_code_prefix INT,
	customer_city VARCHAR (50),
	customer_state VARCHAR (50)
);

COPY customers (customer_id,customer_unique_id,customer_zip_code_prefix,customer_city,customer_state)
FROM 'C:\Program Files\PostgreSQL\15\data\olist\olist_customers_dataset.csv' 
DELIMITER ',' CSV HEADER;

SELECT * FROM customers;

DROP TABLE IF EXISTS geolocation;

CREATE TABLE geolocation (
	geolocation_zip_code_prefix INT,
	geolocation_lat FLOAT,
	geolocation_lng FLOAT,
	geolocation_city VARCHAR(50),
	geolocation_state VARCHAR(10)
);

COPY geolocation (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state)
FROM 'C:\Program Files\PostgreSQL\15\data\olist\olist_geolocation_dataset.csv'
DELIMITER ',' CSV HEADER;

SELECT * FROM geolocation;

DROP TABLE IF EXISTS order_items;

CREATE TABLE order_items (
	order_id VARCHAR(50) NOT NULL,
	order_item_id VARCHAR(50),
	product_id VARCHAR(50),
	seller_id VARCHAR(50),
	shipping_limit_date TIMESTAMP,
	price FLOAT,
	freight_value FLOAT
);

COPY order_items (order_id,order_item_id,product_id,seller_id,shipping_limit_date,price,freight_value)
FROM 'C:\Program Files\PostgreSQL\15\data\olist\olist_order_items_dataset.csv'
DELIMITER ',' CSV HEADER;

SELECT * FROM order_items;

DROP TABLE IF EXISTS order_payments;

CREATE TABLE order_payments (
	order_id VARCHAR(50),
	payment_sequential INT,
	payment_type VARCHAR(50),
	payment_installments INT,
	payment_value FLOAT
);

COPY order_payments (order_id,payment_sequential,payment_type,payment_installments,payment_value)
FROM 'C:\Program Files\PostgreSQL\15\data\olist\olist_order_payments_dataset.csv'
DELIMITER ',' CSV HEADER;

SELECT * FROM order_payments;

DROP TABLE IF EXISTS reviews;

CREATE TABLE reviews (
	review_id VARCHAR(50) NOT NULL,
	order_id VARCHAR(50),
	review_score INT,
	review_comment_title VARCHAR(50),
	review_comment_message VARCHAR(500),
	review_creation_date TIMESTAMP,
	review_answer_timestamp TIMESTAMP
);

COPY reviews (review_id,order_id,review_score,review_comment_title,review_comment_message,review_creation_date,review_answer_timestamp)
FROM 'C:\Program Files\PostgreSQL\15\data\olist\olist_order_reviews_dataset.csv'
DELIMITER ',' CSV HEADER;

SELECT * FROM reviews;

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
	order_id VARCHAR(225) PRIMARY KEY,
	customer_id VARCHAR(225),
	order_status VARCHAR(50),
	order_purchase_timestamp TIMESTAMP,
	order_approved_at TIMESTAMP,
	order_delivered_carrier_date TIMESTAMP,
	order_delivered_customer_date TIMESTAMP,
	order_estimated_delivery_date TIMESTAMP
);

COPY orders (order_id,customer_id,order_status,order_purchase_timestamp,order_approved_at,order_delivered_carrier_date,order_delivered_customer_date,order_estimated_delivery_date)
FROM 'C:\Program Files\PostgreSQL\15\data\olist\olist_orders_dataset.csv'
DELIMITER ',' CSV HEADER;

SELECT * FROM orders;

DROP TABLE IF EXISTS products;

CREATE TABLE products (
	product_id VARCHAR(50) NOT NULL PRIMARY KEY,
	product_category_name VARCHAR(100),
	product_name_lenght INT,
	product_description_lenght INT,
	product_photos_qty INT,
	product_weight_g INT,
	product_length_cm INT,
	product_height_cm INT,
	product_width_cm INT
);

COPY products (product_id,product_category_name,product_name_lenght,product_description_lenght,product_photos_qty,product_weight_g,product_length_cm,product_height_cm,product_width_cm)
FROM 'C:\Program Files\PostgreSQL\15\data\olist\olist_products_dataset.csv'
DELIMITER ',' CSV HEADER;

SELECT * FROM products;

DROP TABLE IF EXISTS sellers;

CREATE TABLE sellers (
	seller_id VARCHAR(50) NOT NULL PRIMARY KEY,
	seller_zip_code_prefix INT,
	seller_city VARCHAR(100),
	seller_state VARCHAR(15)
);

COPY sellers (seller_id,seller_zip_code_prefix,seller_city,seller_state)
FROM 'C:\Program Files\PostgreSQL\15\data\olist\olist_sellers_dataset.csv'
DELIMITER ',' CSV HEADER;

SELECT * FROM sellers;

DROP TABLE IF EXISTS product_category_name_translation;

CREATE TABLE product_category_name_translation (
	product_category_name VARCHAR(100),
	product_category_name_english VARCHAR(100)
);

COPY product_category_name_translation (product_category_name,product_category_name_english)
FROM 'C:\Program Files\PostgreSQL\15\data\olist\product_category_name_translation.csv'
DELIMITER ',' CSV HEADER;

SELECT * FROM product_category_name_translation;