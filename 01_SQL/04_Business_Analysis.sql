Use Olist_Marketing_Analytics;
GO
------------------------------------
-- Business Question 1
-- Which marketing channels generate the most qualified leads and closed deals, and which have the highest conversion rates?
 
--Marketing Channel Conversion Analysis

SELECT
    CASE
        WHEN GROUPING(l.origin) = 1
        THEN 'ALL CHANNELS'
        ELSE l.origin
    END AS marketing_channel,

    COUNT(*) AS total_leads,

    COUNT(d.mql_id) AS closed_deals,

    CAST(
        100.0 * COUNT(d.mql_id) / NULLIF(COUNT(*), 0)
        AS DECIMAL(6,2)
    ) AS conversion_rate_pct

FROM clean_marketing_leads l

LEFT JOIN clean_closed_deals d
    ON l.mql_id = d.mql_id

GROUP BY ROLLUP(l.origin)

ORDER BY
    GROUPING(l.origin) DESC,
    total_leads DESC;
 -------------------------------------------------------------------------------------
 -- Business Question 2
 -- Which Closed Deals Have Matching Sellers?
 -- Seller Matching by Marketing Channel

SELECT
    l.origin AS marketing_channel,

    COUNT(*) AS total_closed_deals,

    SUM(CASE
        WHEN s.seller_id IS NOT NULL
        THEN 1 ELSE 0
    END) AS matched_deals,

    SUM(CASE
        WHEN s.seller_id IS NULL
        THEN 1 ELSE 0
    END) AS unmatched_deals

FROM clean_closed_deals d

JOIN clean_marketing_leads l
    ON d.mql_id = l.mql_id

LEFT JOIN clean_sellers s
    ON d.seller_id = s.seller_id

GROUP BY l.origin

ORDER BY total_closed_deals DESC;
------------------------------------------------------------------------------
-- Business Question 3 and 4
-- Which marketing channels acquired sellers who subsequently generated the highest sales value?
-- Which marketing channel brings sellers who generate the most sales per seller?

-- Sales Value by Marketing Channel

WITH seller_channels AS (
    SELECT
        d.seller_id,
        l.origin AS marketing_channel,
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
     
    CAST(SUM(i.price) AS DECIMAL(18,2)) AS sales_value_brl,

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

GROUP BY sc.marketing_channel

ORDER BY sales_value_brl DESC;
-----------------------------------------------------------------------
-- Business Question 5
-- Which marketing channels convert qualified leads into closed deals fastest?
-- Average Time to Close Deals

SELECT
    l.origin AS marketing_channel,

    COUNT(*) AS closed_deals,

    AVG(DATEDIFF(DAY,
        l.first_contact_date,
        d.won_date
    )) AS avg_days_to_close

FROM clean_marketing_leads l

JOIN clean_closed_deals d
    ON l.mql_id = d.mql_id

GROUP BY l.origin

ORDER BY avg_days_to_close;
----------------------------------------------------------------------
-- Business Question 6
-- How many qualified leads were generated each month, how many eventually converted and what was their conversion rate? 
-- Monthly Marketing Conversion Trend 

SELECT
    CONVERT(VARCHAR(7), l.first_contact_date, 120) AS lead_month,

    COUNT(*) AS total_leads,

    COUNT(d.mql_id) AS closed_deals,

    CAST(
        100.0 * COUNT(d.mql_id) / COUNT(*)
        AS DECIMAL(6,2)
    ) AS conversion_rate_pct

FROM clean_marketing_leads l

LEFT JOIN clean_closed_deals d
    ON l.mql_id = d.mql_id

GROUP BY
    CONVERT(VARCHAR(7), l.first_contact_date, 120)

ORDER BY lead_month;