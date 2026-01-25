/*
Q3 - Regional Performance Analysis (State-level)

Purpose:
- Identify which states generate the majority of delivered orders and merchandise revenue.
- Compare regional differences in order volume, revenue contribution, logistics cost, and customer experience.

Scope & Grain:
- Geography: customer_state (Brazil state)
- Data grain in source: order-level
- Filter: delivered orders only

Metric definitions (project-wide):
- Revenue (merchandise revenue) = SUM(gmv) over delivered orders.
- AOV = AVG(gmv) per delivered order.
- Avg freight = AVG(freight) per delivered order.
- Freight ratio = AVG(freight / NULLIF(gmv,0)) per delivered order.
- Avg review score = AVG(review_score) per delivered order.
*/

SELECT
  customer_state AS state,
  COUNT(*) AS order_count,
  ROUND(AVG(gmv), 2) AS avg_order_value,
  ROUND(SUM(gmv), 2) AS total_revenue,
  ROUND(AVG(freight), 2) AS avg_freight,
  ROUND(AVG(freight / NULLIF(gmv, 0)), 2) AS freight_ratio,
  ROUND(AVG(review_score), 1) AS average_review_score
FROM analytics.fct_orders
WHERE order_status = 'delivered'
GROUP BY 1
ORDER BY total_revenue DESC;
