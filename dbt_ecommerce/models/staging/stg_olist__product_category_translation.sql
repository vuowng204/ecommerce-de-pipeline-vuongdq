
WITH source AS (
    SELECT * FROM {{ source('olist', 'product_category_name_translation') }}
),
renamed AS (
SELECT
    {{ clean_string('product_category_name') }} AS product_category_name,
    TRIM(product_category_name_english)::VARCHAR AS product_category_name_english
FROM source
)
SELECT * FROM renamed