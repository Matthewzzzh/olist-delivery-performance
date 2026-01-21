/*
Q4 – Delivery Efficiency and Delay

Purpose:
  - Measure overall delivery efficiency and quantify how often deliveries miss the estimated delivery date.
  - Establish a baseline for delivery timeliness before analyzing customer experience impact.

Definitions:
  - Actual delivery date: order_delivered_customer_date.
  - Estimated delivery date: order_estimated_delivery_date.
  - Late delivery: An order is considered late if the actual delivery date exceeds the estimated delivery date.
  - Delay days: Number of days an order is delivered after the estimated delivery date (for late orders only).

Key Metrics:
  - Delivered orders: Total number of delivered orders.
  - On-time orders: Delivered orders that met the estimated delivery date.
  - Late orders: Delivered orders that missed the estimated delivery date.
  - On-time rate: On-time orders / delivered orders.
  - Late rate: Late orders / delivered orders.
  - Average delay days: Average number of days delayed, calculated only for late orders.

Methodology:
  - Analysis is restricted to delivered orders with non-null purchase, estimated delivery,
    and actual delivery timestamps to ensure data completeness.
  - Delivery delay is evaluated relative to the platform’s estimated delivery date,
    which represents customer-facing delivery expectations at the time of purchase.

Output:
  - Aggregate delivery efficiency metrics for the full dataset:
    delivered_orders, on_time_orders, late_orders,
    on_time_rate,
*/

WITH Deliver AS(
    SELECT
 
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date,

    case 
        when order_delivered_customer_date > order_estimated_delivery_date Then 1
        else 0
        End AS is_late,

    case
        when order_delivered_customer_date > order_estimated_delivery_date Then
        (order_delivered_customer_date::date - (order_estimated_delivery_date::date)) ::int
        ELSE NULL
        End AS delay_days
    

FROM analytics.orders
WHERE
    order_status = 'delivered'
    AND order_purchase_timestamp is NOT NULL
    AND order_estimated_delivery_date is NOT NULL
    AND order_delivered_customer_date IS NOT NULL

),

deli_statu AS(


SELECT
    
    count(*) as delivered_orders,
    SUM(1 - is_late) AS on_time_orders,
    SUM(is_late)     AS late_orders,
    avg( delay_days) as avg_5days
FROM
    Deliver
)

SELECT 

    delivered_orders,
    on_time_orders,
    late_orders,
    round(on_time_orders / delivered_orders::decimal,2) AS on_time_rate,
    round(late_orders / delivered_orders::decimal,2) AS late_rete,
    round(avg_5days::decimal,2) as avg_delay_days

FROM deli_statu