
-- =========================================================
-- PROJECT: Olist Marketing Analytics
-- FILE: 01_Database_Setup.sql
-- PURPOSE: Create database, load raw tables, verify imports
-- =========================================================


-- 1. CREATE DATABASE

IF DB_ID('Olist_Marketing_Analytics') IS NULL
BEGIN
    CREATE DATABASE Olist_Marketing_Analytics;
END;
GO

-- 2. USE THE PROJECT DATABASE

USE Olist_Marketing_Analytics;
GO


-- =========================================================
-- 3. RAW TABLE IMPORT
-- =========================================================

-- The following 9 CSV files were imported manually:
-- using SSMS -> Tasks -> Import Flat File:

-- Tables created:
-- dbo.raw_marketing_leads
-- dbo.raw_closed_deals
-- dbo.raw_customers
-- dbo.raw_orders
-- dbo.raw_order_items
-- dbo.raw_payments
-- dbo.raw_products
-- dbo.raw_sellers
-- dbo.raw_category_translation

-- No CREATE TABLE queries were written because
-- SSMS Import Flat File created these tables automatically.


-- =========================================================
-- 4. FIX CATEGORY TRANSLATION HEADER ROW
-- =========================================================

-- During import, the CSV header was accidentally imported
-- as the first data row, so it was removed.

-- DELETE FROM dbo.raw_category_translation
-- WHERE product_category_name = 'product_category_name'
--   AND product_category_name_english = 'product_category_name_english';
-- GO


-- =========================================================
-- 5. VERIFY THAT ALL 9 TABLES LOADED SUCCESSFULLY
-- =========================================================

SELECT COUNT(*) AS marketing_leads_rows
FROM dbo.raw_marketing_leads;

SELECT COUNT(*) AS closed_deals_rows
FROM dbo.raw_closed_deals;

SELECT COUNT(*) AS customers_rows
FROM dbo.raw_customers;

SELECT COUNT(*) AS orders_rows
FROM dbo.raw_orders;

SELECT COUNT(*) AS order_items_rows
FROM dbo.raw_order_items;

SELECT COUNT(*) AS payments_rows
FROM dbo.raw_payments;

SELECT COUNT(*) AS products_rows
FROM dbo.raw_products;

SELECT COUNT(*) AS sellers_rows
FROM dbo.raw_sellers;

SELECT COUNT(*) AS category_translation_rows
FROM dbo.raw_category_translation;