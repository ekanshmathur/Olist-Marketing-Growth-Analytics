USE Olist_Marketing_Analytics;
GO

-- Marketing Channel Sales View

CREATE OR ALTER VIEW marketing_channel_sales
AS

WITH seller_channels AS (
    SELECT
        d.seller_id,
        LOWER(TRIM(l.origin)) AS marketing_channel,
        d.won_date,

        ROW_NUMBER() OVER (
            PARTITION BY d.seller_id
            ORDER BY d.won_date, d.mql_id
        ) AS rn

    FROM clean_closed_deals d

    JOIN clean_marketing_leads l
        ON d.mql_id = l.mql_id

    JOIN clean_sellers s
        ON d.seller_id = s.seller_id
)

SELECT
    sc.marketing_channel,

    COUNT(DISTINCT sc.seller_id) AS active_sellers,

    COUNT(DISTINCT o.order_id) AS total_orders,

    CAST(
        SUM(i.price) AS DECIMAL(18,2)
    ) AS sales_value_brl,

    CAST(
        SUM(i.price) / NULLIF(COUNT(DISTINCT sc.seller_id), 0)
        AS DECIMAL(18,2)
    ) AS avg_sales_per_seller_brl

FROM seller_channels sc

JOIN clean_order_items i
    ON sc.seller_id = i.seller_id

JOIN clean_orders o
    ON i.order_id = o.order_id

WHERE sc.rn = 1
    AND o.order_status = 'delivered'
    AND o.order_purchase_timestamp >= sc.won_date

GROUP BY sc.marketing_channel;
GO


-- VERIFY THE VIEW

SELECT *
FROM marketing_channel_sales
ORDER BY sales_value_brl DESC;