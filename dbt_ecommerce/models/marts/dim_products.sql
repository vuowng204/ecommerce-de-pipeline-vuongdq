-- Bỏ 1 vài trường vô nghĩa đi 
WITH products AS (
    SELECT * FROM {{ ref('stg_olist__products') }}
)
SELECT
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_sk,
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g
FROM products