/*
Q2 – Revenue Contribution by Product Category

Purpose:
  - Analyze how total delivered revenue is distributed across product categories.
  - Identify top revenue-driving categories and quantify their contribution share.

Business Definitions:
  - Category revenue: Sum of item-level price for delivered orders within each category.
  - Total revenue: Sum of item-level price across all delivered items.
  - Revenue share: Category revenue divided by total revenue.

Methodological Rationale:
  - Item-level revenue is used instead of order-level revenue to avoid double counting,
    since a single order may contain items from multiple product categories.
  - This ensures that each unit of revenue is attributed to exactly one category,
    and that category shares sum to 100%.

Output:
  - category
  - category_revenue
  - total_revenue
  - revenue_share
  - delivered_orders
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
