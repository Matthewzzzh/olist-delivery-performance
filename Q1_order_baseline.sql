/*
Purpose:
  - Monthly delivered orders and payment-based revenue trend, including MoM change and MoM growth %.

Definitions:
  - Revenue proxy: SUM(payment_total) over delivered orders.
  - MoM change: revenue - LAG(revenue).
  - MoM growth %: (revenue - LAG(revenue)) / LAG(revenue).

Assumptions:
  - Delivered orders only.
*/

WITH monthly AS (
  SELECT
    order_month,
    COUNT(*) AS monthly_orders,
    SUM(payment_total) AS monthly_revenue
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
