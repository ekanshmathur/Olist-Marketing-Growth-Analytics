
-- USE Olist_Marketing_Analytics;
-- GO

-- SELECT TABLE_NAME
-- FROM INFORMATION_SCHEMA.TABLES
-- ORDER BY TABLE_NAME;
--------------------------------------------------------------------------
-- ROW COUNTS
SELECT 'raw_marketing_leads' AS table_name, COUNT(*) AS row_count
FROM raw_marketing_leads

UNION ALL

SELECT 'raw_customers', COUNT(*)
FROM raw_customers

UNION ALL

SELECT 'raw_orders', COUNT(*)
FROM raw_orders

UNION ALL

SELECT 'raw_order_items', COUNT(*)
FROM raw_order_items

UNION ALL
SELECT 'raw_payments', COUNT(*)
FROM raw_payments

UNION ALL
SELECT 'raw_products', COUNT(*)
FROM raw_products

UNION ALL
SELECT 'raw_sellers', COUNT(*)
FROM raw_sellers

UNION ALL
SELECT 'raw_category_translation', COUNT(*)
FROM raw_category_translation

UNION ALL
SELECT 'raw_closed_deals', COUNT(*)
FROM raw_closed_deals;

----------------------------------------------------------------------------

-- Inspecting Column Names and Data Types

SELECT
	TABLE_NAME,
	ORDINAL_POSITION AS columns_position,
	COLUMN_NAME,
	DATA_TYPE,
	CHARACTER_MAXIMUM_LENGTH AS max_length,
	IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
AND TABLE_NAME LIKE 'raw[_]%'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

----------------------------------------------------------------------------
-- VERIFYING ACTUAL MISSING DATES

SELECT
	'Marketing Leads' as Table_name,
	COUNT(*) AS total_rows,
	COUNT(*) - COUNT(first_contact_date) AS missing_dates
FROM raw_marketing_leads

UNION ALL

SELECT
	'Closed Deals',
	COUNT(*),
	COUNT(*) - COUNT(won_date)
FROM raw_closed_deals;

-----------------------------------------------------------------------------
-- Marketing leads

SELECT
	COUNT(*) AS total_rows,
	COUNT(*) - COUNT(mql_id) AS missing_mql_id,
	COUNT(*) - COUNT(landing_page_id) AS missing_landing_page,
	SUM(CASE
		WHEN origin IS NULL OR TRIM(origin) = ''
		THEN 1 ELSE 0
	END) AS missing_origin
FROM raw_marketing_leads;

-- Closed Deals
SELECT COUNT(*) AS total_rows,
    COUNT(*) - COUNT(mql_id) AS missing_mql_id,
    COUNT(*) - COUNT(seller_id) AS missing_seller_id,
    COUNT(*) - COUNT(business_segment) AS missing_segment,
    COUNT(*) - COUNT(lead_type) AS missing_lead_type,
    COUNT(*) - COUNT(business_type) AS missing_business_type,
    COUNT(*) - COUNT(declared_monthly_revenue) AS missing_revenue
FROM raw_closed_deals

SELECT
SUM(CASE
	WHEN NULLIF(TRIM(business_segment),'') IS NULL
	THEN 1
	ELSE 0
END) AS missing_segment,

SUM(CASE
	WHEN NULLIF(TRIM(lead_type),'') IS NULL
	THEN 1
	ELSE 0
END) AS missing_lead_type,

SUM(CASE
	WHEN NULLIF(TRIM(business_type),'') IS NULL
    THEN 1
	ELSE 0
END) AS missing_business_type
FROM raw_closed_deals;

-- Orders

SELECT
    COUNT(*) AS total_orders,
    COUNT(*) - COUNT(order_approved_at) AS missing_approval,
    COUNT(*) - COUNT(order_delivered_carrier_date) AS missing_carrier_date,
    COUNT(*) - COUNT(order_delivered_customer_date) AS missing_delivery_date
FROM raw_orders;

-- Products

SELECT
    COUNT(*) AS total_products,
    SUM(CASE
        WHEN NULLIF(TRIM(product_category_name), '') IS NULL
        THEN 1 ELSE 0
    END) AS missing_category,
    COUNT(*) - COUNT(product_name_lenght) AS missing_name_length,
    COUNT(*) - COUNT(product_description_lenght) AS missing_description,
    COUNT(*) - COUNT(product_photos_qty) AS missing_photos,
    COUNT(*) - COUNT(product_weight_g) AS missing_weight,
    COUNT(*) - COUNT(product_length_cm) AS missing_length,
    COUNT(*) - COUNT(product_height_cm) AS missing_height,
    COUNT(*) - COUNT(product_width_cm) AS missing_width
FROM raw_products;

-- Orders
SELECT
	order_status,
	COUNT(*) AS total_orders,
	SUM(CASE
		WHEN order_delivered_customer_date IS NULL
		THEN 1
		ELSE 0
	END) AS missing_delivery_dates
FROM raw_orders
GROUP BY order_status
ORDER BY missing_delivery_dates DESC;


-- 1. CUSTOMERS
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(customer_id) AS missing_customer_id,
    COUNT(*) - COUNT(customer_unique_id) AS missing_unique_id,
    COUNT(*) - COUNT(customer_zip_code_prefix) AS missing_zip,
    SUM(CASE
        WHEN NULLIF(TRIM(customer_city), '') IS NULL
        THEN 1
        ELSE 0
    END) AS missing_city,
    SUM(CASE
        WHEN NULLIF(TRIM(customer_state), '') IS NULL
        THEN 1
        ELSE 0
    END) AS missing_state
FROM raw_customers;


-- 2. ORDER ITEMS
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(order_id) AS missing_order_id,
    COUNT(*) - COUNT(order_item_id) AS missing_item_id,
    COUNT(*) - COUNT(product_id) AS missing_product_id,
    COUNT(*) - COUNT(seller_id) AS missing_seller_id,
    COUNT(*) - COUNT(shipping_limit_date) AS missing_shipping_date,
    COUNT(*) - COUNT(price) AS missing_price,
    COUNT(*) - COUNT(freight_value) AS missing_freight
FROM raw_order_items;


-- 3. PAYMENTS
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(order_id) AS missing_order_id,
    COUNT(*) - COUNT(payment_sequential) AS missing_sequence,
    SUM(CASE
        WHEN NULLIF(TRIM(payment_type), '') IS NULL
        THEN 1
        ELSE 0
    END) AS missing_payment_type,
    COUNT(*) - COUNT(payment_installments) AS missing_installments,
    COUNT(*) - COUNT(payment_value) AS missing_payment_value
FROM raw_payments;


-- 4. SELLERS
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(seller_id) AS missing_seller_id,
    COUNT(*) - COUNT(seller_zip_code_prefix) AS missing_zip,
    SUM(CASE
        WHEN NULLIF(TRIM(seller_city), '') IS NULL
        THEN 1
        ELSE 0
    END) AS missing_city,
    SUM(CASE
        WHEN NULLIF(TRIM(seller_state), '') IS NULL
        THEN 1
        ELSE 0
    END) AS missing_state
FROM raw_sellers;


-- 5. CATEGORY TRANSLATION
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE
        WHEN NULLIF(TRIM(product_category_name), '') IS NULL
        THEN 1
        ELSE 0
    END) AS missing_portuguese,
    SUM(CASE
        WHEN NULLIF(TRIM(product_category_name_english), '') IS NULL
        THEN 1
        ELSE 0
    END) AS missing_english
FROM raw_category_translation;
-----------------------------------------------------------------------
-- Duplicate Detection - All 9 Tables

SELECT 'Marketing Leads' AS table_name,
       COUNT(*) - COUNT(DISTINCT mql_id) AS duplicates
FROM raw_marketing_leads

UNION ALL
SELECT 'Closed Deals',
       COUNT(*) - COUNT(DISTINCT mql_id)
FROM raw_closed_deals

UNION ALL
SELECT 'Customers',
       COUNT(*) - COUNT(DISTINCT customer_id)
FROM raw_customers

UNION ALL
SELECT 'Orders',
       COUNT(*) - COUNT(DISTINCT order_id)
FROM raw_orders

UNION ALL
SELECT 'Order Items',
       COUNT(*) - COUNT(DISTINCT CONCAT(order_id, '|', order_item_id))
FROM raw_order_items

UNION ALL
SELECT 'Payments',
       COUNT(*) - COUNT(DISTINCT CONCAT(order_id, '|', payment_sequential))
FROM raw_payments

UNION ALL
SELECT 'Products',
       COUNT(*) - COUNT(DISTINCT product_id)
FROM raw_products

UNION ALL
SELECT 'Sellers',
       COUNT(*) - COUNT(DISTINCT seller_id)
FROM raw_sellers

UNION ALL
SELECT 'Category Translation',
       COUNT(*) - COUNT(DISTINCT product_category_name)
FROM raw_category_translation;

---------------------------------------------------------------------------------
-- Relationship Validation

SELECT 'Closed Deals -> Leads' AS relationship,
       COUNT(*) AS unmatched_records
FROM raw_closed_deals d
LEFT JOIN raw_marketing_leads l ON d.mql_id = l.mql_id
WHERE l.mql_id IS NULL

UNION ALL

SELECT 'Closed Deals -> Sellers', COUNT(*)
FROM raw_closed_deals d
LEFT JOIN raw_sellers s ON d.seller_id = s.seller_id
WHERE s.seller_id IS NULL

UNION ALL

SELECT 'Order Items -> Orders', COUNT(*)
FROM raw_order_items i
LEFT JOIN raw_orders o ON i.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT 'Order Items -> Sellers', COUNT(*)
FROM raw_order_items i
LEFT JOIN raw_sellers s ON i.seller_id = s.seller_id
WHERE s.seller_id IS NULL

UNION ALL

SELECT 'Orders -> Customers', COUNT(*)
FROM raw_orders o
LEFT JOIN raw_customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT 'Order Items -> Products', COUNT(*)
FROM raw_order_items i
LEFT JOIN raw_products p ON i.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT 'Payments -> Orders', COUNT(*)
FROM raw_payments p
LEFT JOIN raw_orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT 'Products -> Category Translation', COUNT(*)
FROM raw_products p
LEFT JOIN raw_category_translation t
ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
AND t.product_category_name IS NULL;