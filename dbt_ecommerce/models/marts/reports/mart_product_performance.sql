WITH items AS (
    SELECT * FROM {{ ref('fct_order_items') }}
)
SELECT
    product_sk,
    product_category_name,
    product_category_name_en,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_units_sold,
    SUM(total_item_value) AS total_revenue,
    AVG(item_price) AS avg_selling_price,
    AVG(review_score) AS avg_review_score
FROM items
GROUP BY product_sk, product_category_name, product_category_name_en