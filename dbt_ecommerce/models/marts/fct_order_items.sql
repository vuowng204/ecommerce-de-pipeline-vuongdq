WITH items AS (
    SELECT * 
    FROM {{ ref('int_order_items_enriched') }}
),

orders AS (
    SELECT * 
    FROM {{ ref('int_orders_enriched') }}
),

customers AS (
    SELECT * 
    FROM {{ ref('stg_olist__customers') }}
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['i.order_id', 'i.order_item_id']) }} AS order_item_sk,
        i.order_id,
        i.order_item_id,
        {{ dbt_utils.generate_surrogate_key(['i.product_id']) }} AS product_sk,
        {{ dbt_utils.generate_surrogate_key(['i.seller_id']) }} AS seller_sk,
        
        -- Map qua customer_unique_id để khớp khóa ngoại với dim_customers
        {{ dbt_utils.generate_surrogate_key(['c.customer_unique_id']) }} AS customer_sk,
        
        CAST(o.order_purchase_timestamp AS DATE) AS order_date,
        o.order_status,
        i.product_category_name,
        i.product_category_name_en,
        i.seller_state,
        i.item_price,
        i.freight_value,
        i.total_item_value,
        o.review_score
    FROM items i
    LEFT JOIN orders o ON i.order_id = o.order_id
    LEFT JOIN customers c ON o.customer_id = c.customer_id
)
SELECT * FROM final

