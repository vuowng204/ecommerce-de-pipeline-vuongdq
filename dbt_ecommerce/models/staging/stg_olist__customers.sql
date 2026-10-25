with source as (
    SELECT * FROM {{ source('olist','customers') }}
    limit 5
),
renamed as(
    SELECT
       TRIM(customer_id)::VARCHAR AS customer_id , -- Cột này thực chất là ID 
       TRIM(customer_unique_id)::VARCHAR AS customer_unique_id, -- Cột này mới là ID thật của Khách hàng
        {{ safe_cast('customer_zip_code_prefix', 'INTEGER') }} AS customer_zip_code_prefix,
        {{ clean_string('customer_city') }} AS customer_city,
        {{ clean_string('customer_state') }} AS customer_state
    FROM source
)
SELECT * FROM renamed

