/*
Q5 - Impact of Delivery Delay on Customer Reviews

Purpose:
- Assess whether late deliveries are associated with worse customer ratings.

Definitions:
- Delivery status:
  - on time: delivered_customer_date <= estimated_delivery_date
  - late: delivered_customer_date > estimated_delivery_date
- Low rating: review_score < 3 (order-level)

Metrics:
- orders_count: number of delivered orders per delivery status
- low_rating_orders: number of orders with review_score < 3
- low_rating_rate: low_rating_orders / orders_count
- avg_rate: average review score per delivery status
*/

WITH base AS (
  SELECT
    ao.order_id,
    afo.review_score,
    CASE
      WHEN ao.order_delivered_customer_date > ao.order_estimated_delivery_date THEN 'late'
      ELSE 'on time'
    END AS deliver_status,
    CASE
      WHEN afo.review_score < 3 THEN 1
      ELSE 0
    END AS is_low_rating
  FROM analytics.orders AS ao
  JOIN analytics.fct_orders AS afo
    ON ao.order_id = afo.order_id
  WHERE ao.order_status = 'delivered'
    AND ao.order_delivered_customer_date IS NOT NULL
    AND ao.order_estimated_delivery_date IS NOT NULL
    AND afo.review_score IS NOT NULL
)

SELECT
  deliver_status,
  COUNT(*) AS orders_count,
  SUM(is_low_rating) AS low_rating_orders,
  ROUND(SUM(is_low_rating)::numeric / COUNT(*), 3) AS low_rating_rate,
  ROUND(AVG(review_score), 2) AS avg_rate
FROM base
GROUP BY deliver_status;

