WITH source AS (
    SELECT * FROM {{ source('olist','orders')}}
),
renamed AS (
    SELECT
       TRIM(order_id)::VARCHAR AS order_id,
       TRIM(customer_id)::VARCHAR AS customer_id,
       {{ clean_string('order_status') }} AS order_status,
       CAST(order_purchase_w AS TIMESTAMP),
       CAST(order_approved_at AS TIMESTAMP),
       CAST(order_delivered_carrier_date AS TIMESTAMP),
       CAST(order_delivered_customer_date AS TIMESTAMP),
       CAST(order_estimated_delivery_date AS TIMESTAMP)
    FROM source
)

SELECT * FROM renamed