WITH source AS (
    SELECT * FROM {{ source('olist', 'sellers') }}
),
renamed AS (
    SELECT
        TRIM(seller_id)::VARCHAR AS seller_id,
        {{ clean_string('seller_zip_code_prefix')}} AS seller_zip_code_prefix,
        {{ clean_string('seller_city') }} AS seller_city,
        {{ clean_string('seller_state') }} AS seller_state
    FROM source
)
SELECT * FROM renamed
