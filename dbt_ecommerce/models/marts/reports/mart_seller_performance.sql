WITH items AS (
    SELECT * FROM {{ ref('fct_order_items') }}
),
orders AS (
    SELECT order_id, order_status, review_score FROM {{ ref('fct_orders') }}
),
joined AS (
    SELECT
        i.seller_sk,
        i.seller_state,
        i.order_id,
        i.item_price,
        i.freight_value,
        i.total_item_value,
        o.order_status,
        o.review_score
    FROM items i
    LEFT JOIN orders o ON i.order_id = o.order_id
),
final AS (
    SELECT
        seller_sk,
        seller_state,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(total_item_value) AS total_revenue,
        SUM(freight_value) AS total_freight,
        AVG(item_price) AS avg_item_price,
        AVG(review_score) AS avg_review_score,
        SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END) AS canceled_orders
    FROM joined
    GROUP BY seller_sk, seller_state
)
SELECT * FROM final