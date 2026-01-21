/*
Q3 – Regional Performance Analysis (State-level)

Purpose:
  - Identify which regions (states) generate the majority of orders and revenue.
  - Compare regional differences in order volume, revenue contribution, logistics cost, and customer experience.

Scope & Grain:
  - Geographic level: State
  - Grain: Order-level
  - Order filter: Delivered orders only (realized outcomes)

Key Metrics:
  - Order count: Number of delivered orders per state.
  - Total revenue: Sum of payment_total per state.
  - Average order value (AOV): Average payment_total per order.
  - Average freight: Average freight cost per order.
  - Freight ratio: Average freight-to-GMV ratio (freight / gmv).
  - Average review score: Mean customer review score per state.

Methodology:
  - Revenue and customer experience metrics are calculated at the order level
    to ensure consistency with realized fulfillment outcomes.
  - Window functions are used to compute state-level aggregates while
    preserving row-level granularity.
  - States are ranked by total revenue to identify core versus peripheral regions.

Output:
  - One row per state with consolidated performance metrics:
    state, order_count, avg_order_value, total_revenue,
    avg_freight, freight_ratio, average_review_score

Executive Summary:
  - Orders and revenue are highly concentrated in a small number of core states, led by SP.
  - Core regions exhibit lower freight-to-GMV ratios while maintaining stable review scores.
  - Peripheral regions tend to incur higher logistics costs, but customer satisfaction
    does not deteriorate proportionally, suggesting adjusted delivery expectations.
*/

SELECT
    DISTINCT customer_state AS state,
    count (order_id) over(PARTITION BY customer_state) AS order_count,
    Round(avg(payment_total) over(PARTITION by customer_state),2) AS avg_order_value,
    SUM (payment_total) over(PARTITION BY customer_state) AS total_revenue,
    Round(avg (freight) over (PARTITION by customer_state),2) as avg_freight,
    Round(avg (freight / gmv) over (PARTITION by customer_state),2) AS frieight_ratio ,
    Round(avg(review_score) over(PARTITION by (customer_state)),1) AS average_review_score
FROM
    analytics.fct_orders
WHERE 
    order_status = 'delivered'  
ORDER BY  total_revenue DESC

/*Q3 Executive Summary（你可以直接用）

Orders and revenue are highly concentrated in a few core states, led by SP.

Core regions show lower freight-to-GMV ratios while maintaining stable review scores.

Peripheral regions incur higher logistics costs, but customer satisfaction does not deteriorate proportionally, 

suggesting adjusted delivery expectations by customers.
*/