WITH source AS (
    SELECT * FROM {{ source('olist', 'products') }}
),
renamed AS (
    SELECT
        TRIM(product_id)::VARCHAR AS product_id,
        {{ clean_string('product_category_name') }} AS product_category_name,
        {{ safe_cast('product_name_lenght', 'INTEGER') }} AS product_name_length,         -- sửa typo
        {{ safe_cast('product_description_lenght', 'INTEGER') }} AS product_description_length, -- sửa typo
        {{ safe_cast('product_photos_qty', 'INTEGER') }} AS product_photos_qty,
        {{ safe_cast('product_weight_g', 'NUMERIC(10,2)') }} AS product_weight_g 
    FROM source
)
SELECT * FROM renamed