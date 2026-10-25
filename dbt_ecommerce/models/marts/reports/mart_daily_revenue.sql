WITH orders AS (
    SELECT * FROM {{ ref('fct_orders') }}
)
SELECT
    order_date,
    COALESCE(COUNT(DISTINCT order_id),0) AS total_orders,
    COALESCE(SUM(total_payment_value),0) AS total_revenue,
    COALESCE(SUM(total_item_value),0) AS total_gmv,
    COALESCE(SUM(total_freight_value),0) AS total_freight,
    COALESCE(AVG(total_payment_value),0) AS avg_order_value,
    COALESCE(AVG(review_score),0) AS avg_review_score
FROM orders
WHERE order_status NOT IN ('canceled', 'unavailable')
GROUP BY order_date
ORDER BY order_date DESC