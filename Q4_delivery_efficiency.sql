/*
Q4 - Delivery Efficiency and Delay

Purpose:
- Measure overall delivery efficiency and quantify how often deliveries miss the estimated delivery date.
- Establish a baseline for delivery timeliness before analyzing customer experience impact.

Definitions:
- Actual delivery date: order_delivered_customer_date
- Estimated delivery date: order_estimated_delivery_date
- Late delivery: order_delivered_customer_date > order_estimated_delivery_date
- Delay days: (order_delivered_customer_date::date - order_estimated_delivery_date::date), calculated only for late orders.

Key Metrics:
- delivered_orders: total number of delivered orders with non-null estimated and actual delivery dates
- on_time_orders: delivered orders delivered on or before estimated date
- late_orders: delivered orders delivered after estimated date
- on_time_rate: on_time_orders / delivered_orders
- late_rate: late_orders / delivered_orders
- avg_delay_days: average delay days for late orders only

Data source note:
- Use analytics.orders because it contains order_estimated_delivery_date required for delay calculation.
*/

WITH delivered AS (
  SELECT
    order_id,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    CASE
      WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1
      ELSE 0
    END AS is_late,
    CASE
      WHEN order_delivered_customer_date > order_estimated_delivery_date
        THEN (order_delivered_customer_date::date - order_estimated_delivery_date::date)
      ELSE NULL
    END AS delay_days
  FROM analytics.orders
  WHERE order_status = 'delivered'
    AND order_estimated_delivery_date IS NOT NULL
    AND order_delivered_customer_date IS NOT NULL
),
agg AS (
  SELECT
    COUNT(*) AS delivered_orders,
    SUM(CASE WHEN is_late = 0 THEN 1 ELSE 0 END) AS on_time_orders,
    SUM(CASE WHEN is_late = 1 THEN 1 ELSE 0 END) AS late_orders,
    ROUND(AVG(delay_days)::numeric, 2) AS avg_delay_days
  FROM delivered
)
SELECT
  delivered_orders,
  on_time_orders,
  late_orders,
  ROUND(on_time_orders::numeric / NULLIF(delivered_orders, 0), 2) AS on_time_rate,
  ROUND(late_orders::numeric / NULLIF(delivered_orders, 0), 2) AS late_rate,
  avg_delay_days
FROM agg;
