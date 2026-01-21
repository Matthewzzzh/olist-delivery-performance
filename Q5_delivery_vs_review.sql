/*5.	延迟对评分的影响
•	交付延迟是否会显著降低 review_score？
•	指标：On-time vs Late 的平均评分差异、低分率差异


deliver status | orders_count | low_rate_count | low_rating_rate | avg_rate

每一行= deliver status
deliver status "on time" = expected date > deliver date
deliver status "late" = expected date < deliver date
orders_count = count of orders (item-lvl,delivered)
low_rate_count = count of orders with rating< 3
low_rating_rate = low_rate_count / orders/count
avg_rate = average of rating of all orders 

*/


WITH base AS (

    SELECT
    ao.order_id,
    afo.review_score,
    CASE
        WHEN ao.order_delivered_customer_date > ao.order_estimated_delivery_date Then 'late'
        ELSE 'on time'
        END AS deliver_status,
    CASE
        WHEN afo.review_score < 3 Then 1
        ELSE 0
        END AS rate_ranking

FROM
    analytics.orders AS AO
    JOIN analytics.fct_orders AS AFO on ao.order_id = AFO.order_id 

    WHERE ao.order_status = 'delivered'
    AND ao.order_delivered_customer_date IS NOT NULL
    AND ao.order_estimated_delivery_date is not NULL
)


SELECT
    deliver_status,
    count (*) as orders_count,
    SUM(rate_ranking ) AS low_rate_count,
    Round( ((SUM(rate_ranking)::numeric )/ (count(*)::numeric) )::numeric,3) AS low_rating_rate,
    round(avg(review_score),2) AS avg_rate

FROM
    base
GROUP BY deliver_status

/*
“We found that late deliveries are strongly associated with worse customer experience.
Late orders had an average rating of 2.57 compared to 4.30 for on-time orders, 
and more than half of late orders received low ratings (≤3), versus only 9% for on-time deliveries.”
*/


