-- 1. How much the total revenue, number of orders, number of items sold, and number of customers over time?
SELECT 
	SUM(COALESCE(payment_value, (price + freight_value)))::int AS total_revenue,
	COUNT(DISTINCT o.order_id) AS total_order,
	COUNT(product_id) AS total_items_sold,
	COUNT(DISTINCT customer_unique_id) AS total_customer
FROM orders AS o
JOIN order_payments AS op ON o.order_id = op.order_id
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN customers AS c ON o.customer_id = c.customer_id;

-- 2. What is the growth rate of the total revenue, number of orders, number of items sold, and number of customers over the month?
WITH monthly_growth_not_fixed AS (
	-- In this CTE, May 2016 not included to the rows because no revenue in that month. We will fix it later.
	SELECT 
		DATE_TRUNC('month', order_purchase_timestamp) AS month_year, 
		SUM(COALESCE(payment_value, (price + freight_value)))::int AS total_revenue,
		COUNT(DISTINCT o.order_id) AS total_order,
		COUNT(product_id) AS total_items_sold,
		COUNT(DISTINCT customer_unique_id) AS total_customer
	FROM orders AS o
	JOIN order_payments AS op ON o.order_id = op.order_id
	JOIN order_items AS oi ON o.order_id = oi.order_id
	JOIN customers AS c ON o.customer_id = c.customer_id
	GROUP BY 1
),
monthly_growth AS (
	SELECT 
		a.month_year, total_revenue, total_order, total_items_sold, total_customer
	FROM (
		SELECT generate_series(
			DATE_TRUNC('month', MIN(order_purchase_timestamp)),
			DATE_TRUNC('month', MAX(order_purchase_timestamp)),
			'1 month'::interval) AS month_year -- add Nov 2016 to the rows to calculate growth rate correctly
		FROM orders) AS a
	LEFT JOIN monthly_growth_not_fixed AS b ON a.month_year = b.month_year
	ORDER BY 1)

SELECT *,
	ROUND(
		(COALESCE(total_revenue::numeric, 0) - LAG(COALESCE(total_revenue::numeric, 0)) OVER (ORDER BY month_year)) / 
		LAG(COALESCE(total_revenue::numeric, NULL)) OVER (ORDER BY month_year) * 100, 1) AS revenue_growth,
	ROUND(
		(COALESCE(total_order::numeric, 0) - LAG(COALESCE(total_order::numeric, 0)) OVER (ORDER BY month_year)) / 
		LAG(COALESCE(total_order::numeric, NULL)) OVER (ORDER BY month_year) * 100, 1) AS order_growth,
	ROUND(
		(COALESCE(total_items_sold::numeric, 0) - LAG(COALESCE(total_items_sold::numeric, 0)) OVER (ORDER BY month_year)) / 
		LAG(COALESCE(total_items_sold::numeric, NULL)) OVER (ORDER BY month_year) * 100, 1) AS items_sold_growth,
	ROUND(
		(COALESCE(total_customer::numeric, 0) - LAG(COALESCE(total_customer::numeric, 0)) OVER (ORDER BY month_year)) / 
		LAG(COALESCE(total_customer::numeric, NULL)) OVER (ORDER BY month_year) * 100, 1) AS customer_growth
FROM monthly_growth
ORDER BY 1;

-- 3. What is the trend in total revenue, number of orders, number of items sold, and number of customers across different weekdays over time?
SELECT 
	EXTRACT(DOW FROM order_purchase_timestamp) AS weekdays,
	TO_CHAR(DATE_TRUNC('day', order_purchase_timestamp), 'Day') AS day_name,
	SUM(COALESCE(payment_value, (price + freight_value)))::int AS total_revenue,
	COUNT(DISTINCT o.order_id) AS total_order,
	COUNT(product_id) AS total_items_sold,
	COUNT(DISTINCT customer_unique_id) AS total_customer
FROM orders AS o
JOIN order_payments AS op ON o.order_id = op.order_id
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN customers AS c ON o.customer_id = c.customer_id
GROUP BY 1,2
ORDER BY 1;

-- 4. How do different product categories perform in terms of total revenue, number of orders, number of items sold, and number of customers?
SELECT INITCAP(REPLACE(product_category_name_english,'_',' ')) AS product_category, 
	SUM(COALESCE(payment_value, (price + freight_value)))::int AS total_revenue,
	COUNT(DISTINCT o.order_id) AS total_order,
	COUNT(p.product_id) AS total_items_sold,
	COUNT(DISTINCT c.customer_unique_id) AS total_customer
FROM orders AS o
JOIN order_payments AS op ON o.order_id = op.order_id
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN products AS p ON oi.product_id = p.product_id
JOIN product_category_name_translation AS pc ON p.product_category_name = pc.product_category_name
JOIN customers AS c ON o.customer_id = c.customer_id
GROUP BY 1
ORDER BY 2 DESC, 3 DESC, 4 DESC, 5 DESC;

-- 5. What are the preferred payment types?
SELECT 
	INITCAP(REPLACE(op.payment_type,'_',' ')) AS payment_types,
	SUM(COALESCE(payment_value, (price + freight_value)))::int AS total_revenue,
	COUNT(DISTINCT o.order_id) AS total_order,
	COUNT(product_id) AS total_items_sold,
	COUNT(DISTINCT customer_unique_id) AS total_customer
FROM orders AS o
JOIN order_payments AS op ON o.order_id = op.order_id
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN customers AS c ON o.customer_id = c.customer_id
GROUP BY 1
ORDER BY 2 DESC, 3 DESC, 4 DESC, 5 DESC;

-- 6. How does the delivery types(inter-state or within-state delivery) affect the total revenue, 
-- number of orders, number of items sold, and number of customers?
SELECT 
	CASE WHEN c.customer_state = s.seller_state THEN 'Within-State Delivery'
		ELSE 'Inter-State Delivery' END AS delivery_types,
	SUM(COALESCE(payment_value, (price + freight_value)))::int AS total_revenue,
	COUNT(DISTINCT o.order_id) AS total_order,
	COUNT(product_id) AS total_items_sold,
	COUNT(DISTINCT customer_unique_id) AS total_customer
FROM orders AS o
JOIN order_payments AS op ON o.order_id = op.order_id
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN customers AS c ON o.customer_id = c.customer_id
JOIN sellers AS s ON oi.seller_id = s.seller_id
GROUP BY 1;

-- 7. How does the timeliness of deliveries(late or on-time delivery based on estimated delivery time) affect the total revenue, 
-- number of orders, number of items sold, and number of customers?
SELECT 
	CASE WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'On-time Delivery'
		ELSE 'Late Delivery' END AS delivery_timeliness,
	SUM(COALESCE(payment_value, (price + freight_value)))::int AS total_revenue,
	COUNT(DISTINCT o.order_id) AS total_order,
	COUNT(product_id) AS total_items_sold,
	COUNT(DISTINCT customer_unique_id) AS total_customer
FROM orders AS o
JOIN order_payments AS op ON o.order_id = op.order_id
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN customers AS c ON o.customer_id = c.customer_id
GROUP BY 1;

-- 8. How does state performance based on customer and seller impact total revenue, number of orders, 
-- number of items sold, and number of customers?
(SELECT 
	'customer' AS performance_based_on,
	customer_state AS state,
	SUM(COALESCE(payment_value, (price + freight_value)))::int AS total_revenue,
	COUNT(DISTINCT o.order_id) AS total_order,
	COUNT(product_id) AS total_items_sold,
	COUNT(DISTINCT customer_unique_id) AS total_customer
FROM orders AS o
JOIN order_payments AS op ON o.order_id = op.order_id
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN customers AS c ON o.customer_id = c.customer_id
GROUP BY 1,2
ORDER BY 1, 3 DESC, 4 DESC, 5 DESC, 6 DESC
LIMIT 3)
UNION ALL
(SELECT 
	'seller' AS performance_based_on,
	seller_state AS state,
	SUM(COALESCE(payment_value, (price + freight_value)))::int AS total_revenue,
	COUNT(DISTINCT o.order_id) AS total_order,
	COUNT(product_id) AS total_items_sold,
	COUNT(DISTINCT customer_unique_id) AS total_customer
FROM orders AS o
JOIN order_payments AS op ON o.order_id = op.order_id
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN customers AS c ON o.customer_id = c.customer_id
JOIN sellers AS s ON oi.seller_id = s.seller_id
GROUP BY 1,2
ORDER BY 1, 3 DESC, 4 DESC, 5 DESC, 6 DESC
LIMIT 3);

-- 9. How does city performance based on customer and seller impact total revenue, number of orders, 
-- number of items sold, and number of customers?
(SELECT 
	'customer' AS performance_based_on,
	INITCAP(customer_city) AS city,
	SUM(COALESCE(payment_value, (price + freight_value)))::int AS total_revenue,
	COUNT(DISTINCT o.order_id) AS total_order,
	COUNT(product_id) AS total_items_sold,
	COUNT(DISTINCT customer_unique_id) AS total_customer
FROM orders AS o
JOIN order_payments AS op ON o.order_id = op.order_id
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN customers AS c ON o.customer_id = c.customer_id
GROUP BY 1,2
ORDER BY 1, 3 DESC, 4 DESC, 5 DESC, 6 DESC
LIMIT 3)
UNION ALL
(SELECT 
	'seller' AS performance_based_on,
	INITCAP(seller_city) AS city,
	SUM(COALESCE(payment_value, (price + freight_value)))::int AS total_revenue,
	COUNT(DISTINCT o.order_id) AS total_order,
	COUNT(product_id) AS total_items_sold,
	COUNT(DISTINCT customer_unique_id) AS total_customer
FROM orders AS o
JOIN order_payments AS op ON o.order_id = op.order_id
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN customers AS c ON o.customer_id = c.customer_id
JOIN sellers AS s ON oi.seller_id = s.seller_id
GROUP BY 1,2
ORDER BY 1, 3 DESC, 4 DESC, 5 DESC, 6 DESC
LIMIT 3);

-- 10. What is the relationship between the number of reviews and the average review score? 
-- Are products with higher number of reviews receiving more avg reviews score?
SELECT 
	p.product_id,
	INITCAP(REPLACE(product_category_name_english,'_',' ')) AS product_category,
	COUNT(DISTINCT review_id) AS number_of_reviews,
	ROUND(AVG(review_score),1) AS avg_review_score
FROM orders AS o
JOIN reviews AS r ON o.order_id = r.order_id
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN products AS p ON oi.product_id = p.product_id
JOIN product_category_name_translation AS pc ON p.product_category_name = pc.product_category_name
GROUP BY 1,2
ORDER BY 3 DESC, 4 DESC
LIMIT 10;
