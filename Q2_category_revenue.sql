/*
Q2 - Revenue Contribution by Product Category

Purpose:
- Measure how delivered merchandise revenue is distributed across product categories.
- Identify top revenue-driving categories and quantify contribution share.

Metric definitions (project-wide):
- Revenue = merchandise value (SUM(oi.price)) for delivered orders only.
- Shipping/freight and payment_total are excluded from revenue.

Notes:
- delivered_orders = number of distinct delivered orders that contain at least one item in the category.
  This metric is NOT additive across categories (one order can include multiple categories).
*/



WITH base AS (
    SELECT
        ct.product_category_name_english AS category,
        SUM(oi.price)                   AS category_revenue,
        COUNT(DISTINCT oi.order_id)     AS delivered_orders
    FROM analytics.order_items oi
    JOIN analytics.orders o
        ON oi.order_id = o.order_id
    JOIN analytics.products p
        ON oi.product_id = p.product_id
    JOIN analytics.category_translation ct
        ON p.product_category_name = ct.product_category_name
    WHERE o.order_status = 'delivered'
      AND p.product_category_name IS NOT NULL
    GROUP BY 1
),
final AS (
    SELECT
        category,
        category_revenue, 
        delivered_orders,
        SUM(category_revenue) OVER () AS total_revenue,
        ROUND(category_revenue / NULLIF(SUM(category_revenue) OVER (), 0), 4) AS revenue_share
    FROM base
)
SELECT
    category,
    category_revenue,
    total_revenue,
    revenue_share,
    delivered_orders
FROM final
ORDER BY category_revenue DESC;
