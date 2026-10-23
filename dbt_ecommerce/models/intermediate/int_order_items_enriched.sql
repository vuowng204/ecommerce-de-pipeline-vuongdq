WITH items AS (
    slect * FROM {{ ref('stg_olist__order_items') }}
),
product AS (
    SELECT * FROM {{ ref('stg_olist__products') }}
),
seller AS (
    SELECT * FROM {{ ref('stg_olist__sellers') }}
),
category_translation AS (
    SELECT * FROM {{ ref('stg_olist__product_category_translation') }}
),
joined AS (
    SELECT
        i.order_id,
        i.order_item_id,
        i.product_id,
        p.product_category_name,
        COALESCE(ct.product_category_name_english,'SAN PHAM KHONG CO TEN TIENG ANH') AS product_category_name_english,
        i.seller_id,
        s.seller_state,
        s.seller_city
        i.shipping_limit_date,
        i.price AS item_price,
        i.freight_value,
        i.price + i.freight_value AS total_item_value
    FROM items i
    LEFT JOIN products p ON i.product_id = p.product_id
    LEFT JOIN category_translation ct ON p.product_category_name = ct.product_category_name
    LEFT JOIN sellers s ON i.seller_id = s.seller_id      
)
SELECT * FROM joined