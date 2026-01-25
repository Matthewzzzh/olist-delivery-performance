/*
Q6 - Revenue Exposure from Undelivered Orders (Upper-Bound Estimate)

Purpose:
- Estimate the potential revenue at risk due to orders that were not successfully delivered.
- Provide an upper-bound view of revenue exposure related to fulfillment failures.

Definitions:
- Undelivered order: any order with order_status <> 'delivered'.
- Revenue basis: merchandise value (gmv).
- Lost value (upper bound): sum of gmv for undelivered orders, assuming zero revenue realization.

Notes:
- This is an upper-bound estimate. Some undelivered orders may still be fulfilled later,
  partially refunded, or eventually delivered.
- The metric represents potential revenue exposure rather than realized revenue loss.

Output:
- count_undelivered_orders
- count_total_orders
- undelivered_rate
- potential_lost_value
*/



WITH base AS
(
SELECT
    gmv,
    order_id,

CASE WHEN order_status <> 'delivered' THEN 'undelivered'
     ELSE order_status
     END AS deli_status


FROM
analytics.fct_orders
)


SELECT
    count(case when deli_status = 'undelivered' then 1 END) as count_of_undelivered,
    count(order_id) AS count_total_order,
    round((count(case when deli_status = 'undelivered' then 1 END)::numeric / count(order_id)::numeric),2) AS undelivered_rate,
    sum( case when deli_status = 'undelivered' THEN gmv else 0 END) AS lost_value
FROM
    base

