WITH orders AS (
    SELECT * FROM {{ ref('fct_orders') }}
)
SELECT
    order_date,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_payment_value) AS total_revenue,
    SUM(total_item_value) AS total_gmv,
    SUM(total_freight_value) AS total_freight,
    AVG(total_payment_value) AS avg_order_value,
    AVG(review_score) AS avg_review_score
FROM orders
WHERE order_status NOT IN ('canceled', 'unavailable')
GROUP BY order_date
ORDER BY order_date DESC