/*Q6
    取消/未交付造成的损失
•	取消/不可用订单占比多少？潜在收入损失大概多少（用支付金额或订单项估算）
•	指标：Cancel rate / Undelivered rate + “lost value” estimate

count_of_undelivered | count_total_order | undelivered_rate | lost_value

count_of_undelivered = orders with non "delivered" stauts(include processing, shiping, NULL,etc)
count_of_order = count of all orders(deli + undeli)
undelivered_rate = count of undelivered / count of all orders
lost_value = revenue of undelivered orders(item-lvl)
*/


WITH base AS
(
SELECT
    payment_total,
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
    sum( case when deli_status = 'undelivered' THEN payment_total else 0 END) AS lost_value
FROM
    base

/*
Approximately 3% of orders were undelivered, corresponding to an estimated $586K in potential revenue exposure,
 indicating that fulfillment failures represent a non-trivial business risk beyond customer experience.
 */
 