/*
-- Revenue proxy: SUM(gmv) over delivered orders.
-- Note:
-- Early months may contain delivered orders with very low or zero GMV
-- due to promotions, discounts, or incomplete commercial activity,
-- which can result in 0 revenue and abnormal MoM values.

*/

WITH monthly AS (
  SELECT
    order_month,
    COUNT(*) AS monthly_orders,
    SUM(gmv) AS monthly_revenue
  FROM analytics.fct_orders
  WHERE order_status = 'delivered'
  GROUP BY 1
),
final AS (
  SELECT
    order_month,
    monthly_orders,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY order_month) AS prev_month_revenue,
    monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY order_month) AS mom_change,
    ROUND(
      (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY order_month))::numeric
      / NULLIF(LAG(monthly_revenue) OVER (ORDER BY order_month), 0),
      4
    ) AS mom_growth_pct
  FROM monthly
)
SELECT *
FROM final
ORDER BY order_month;
