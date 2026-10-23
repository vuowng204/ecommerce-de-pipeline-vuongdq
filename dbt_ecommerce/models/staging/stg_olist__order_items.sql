WITH source AS (
    SELECT * FROM {{ source('olist','order_items') }}
),
renamed AS(
    SELECT
        TRIM(order_id)::VARCHAR AS order_id,
        {{ safe_cast('order_item_id', 'INTEGER') }} AS order_item_id,
        TRIM(product_id)::VARCHAR AS product_id,
        TRIM(seller_id)::VARCHAR AS seller_id,
        CAST(NULLIF(shipping_limit_date, '') AS TIMESTAMP) AS shipping_limit_date,
        {{ safe_cast('price', 'NUMERIC(10,2)') }} AS price,
        {{ safe_cast('freight_value', 'NUMERIC(10,2)') }} AS freight_value
    FROM source
)
SELECT * FROM renamed