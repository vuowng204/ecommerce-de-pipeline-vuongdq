WITH source AS (
    SELECT * FROM {{ source('olist', 'products') }}
),
renamed AS (
    SELECT
        product_id,
        product_category_name,
        -- Sửa lỗi typo từ dataset gốc
        CAST(product_name_lenght AS INTEGER) AS product_name_length,
        CAST(product_description_lenght AS INTEGER) AS product_description_length,
        CAST(product_photos_qty AS INTEGER) AS product_photos_qty,
        CAST(product_weight_g AS NUMERIC(10,2)) AS product_weight_g
    FROM source
)
SELECT * FROM renamed