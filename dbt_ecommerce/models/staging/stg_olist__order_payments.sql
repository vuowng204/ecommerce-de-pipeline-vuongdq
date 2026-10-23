WITH source AS (
    SELECT * FROM {{ source('olist','order_payments') }}
),
renamed AS (
    SELECT
        TRIM(order_id)::VARCHAR AS order_id,
        {{ safe_cast('payment_sequential', 'INTEGER') }} AS payment_sequential,
        {{ clean_string('payment_type') }} AS payment_type,
        {{ safe_cast('payment_installments', 'INTEGER') }} AS payment_installments,
        {{ safe_cast('payment_value', 'NUMERIC(10,2)') }} AS payment_value
    FROM source
)
SELECT * FROM renamed