
USE Olist_Marketing_Analytics;
GO
--------------------------------------------------------------------
-- REMOVE OLD CLEAN TABLES IF THEY ALREADY EXIST.

DROP TABLE IF EXISTS clean_marketing_leads;

DROP TABLE IF EXISTS clean_closed_deals;

-- CREATE CLEAN TABLES
SELECT *
INTO clean_marketing_leads
FROM raw_marketing_leads;

SELECT *
INTO clean_closed_deals
FROM raw_closed_deals;

--------------------------------------------------------------------
-- CLEAN MARKETING LEADS
UPDATE clean_marketing_leads
SET origin = COALESCE(NULLIF(TRIM(origin), ''),'Unknown');

-- CLEANING CLOSED DEALS
UPDATE clean_closed_deals
SET 
	business_segment = COALESCE(NULLIF(TRIM(business_segment), ''), 'Unknown'),
	lead_type = COALESCE(NULLIF(TRIM(lead_type), ''), 'Unknown'),
	business_type = COALESCE(NULLIF(TRIM(business_type), ''), 'Unknown')

--------------------------------------------------------------------
-- VERIFY ROW COUNTS

SELECT
	'Marketing Leads' as table_name,
	COUNT(*) AS total_rows
FROM clean_marketing_leads

UNION ALL 

SELECT
	'Closed Deals',
	COUNT(*)
FROM clean_closed_deals;
--------------------------------------------------------------------
-- CREATE REMAINING CLEAN TABLES.

SELECT * INTO clean_customers FROM raw_customers; 
SELECT * INTO clean_orders FROM raw_orders; 
Select * INTO clean_order_items from raw_order_items;
SELECT * INTO clean_payments FROM raw_payments; 
Select * into clean_products from raw_products; 
Select * into clean_sellers from raw_sellers;
SELECT * INTO clean_category_translation FROM raw_category_translation 

UPDATE clean_customers SET customer_city = LOWER(TRIM(customer_city)), customer_state = UPPER(TRIM(customer_state));
UPDATE clean_sellers SET seller_city = LOWER(TRIM(seller_city)), seller_state = UPPER(TRIM(seller_state)); 
UPDATE clean_orders SET order_status = lOWER(TRIM(order_status));
UPDATE clean_paymentS SET payment_type = LOWER(TRIM(payment_type));
UPDATE clean_products SET product_category_name = COALESCE(NULLIF(TRIM(product_category_name), ''),'Unknown');
UPDATE clean_category_translation SET product_category_name = TRIM(product_category_name), product_category_name_english = TRIM(product_category_name_english); 

-------------------------------------------------------------------
--  VERIFY CLEAN TABLE ROW COUNTS

SELECT 'Customers' AS table_name, COUNT(*) AS total_rows
FROM clean_customers

UNION ALL

SELECT 'Orders', COUNT(*) FROM clean_orders

UNION ALL

SELECT 'Order Items', COUNT(*) FROM clean_order_items

UNION ALL

SELECT 'Payments', COUNT(*) FROM clean_payments

UNION ALL

SELECT 'Products', COUNT(*) FROM clean_products

UNION ALL

SELECT 'Sellers', COUNT(*) FROM clean_sellers

UNION ALL

SELECT 'Category Translation', COUNT(*)
FROM clean_category_translation;

-- VERIFY OUTSTANDING DATA QUALITY ISSUES

SELECT
	(SELECT COUNT(*)
	 FROM clean_products
	 WHERE product_category_name = 'Unknown') AS unknown_product_categories,

	 (SELECT COUNT(*)
	 FROM clean_orders
	 WHERE order_status = 'delivered'
	 AND order_delivered_customer_date IS NULL) AS delivered_order_status_missing_date;
-------------------------------------------------------------------------------------------------------