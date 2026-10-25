WITH orders AS (
    SELECT * FROM {{ ref('int_orders_enriched') }}
),

customers AS (
    SELECT * FROM {{ ref('stg_olist__customers') }}
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['o.order_id']) }} AS order_sk,
        o.order_id,
        
        -- QUAN TRỌNG: Lấy customer_unique_id để băm ra customer_sk khớp với dim_customers
        {{ dbt_utils.generate_surrogate_key(['c.customer_unique_id']) }} AS customer_sk,
        
        CAST(o.order_purchase_timestamp AS DATE) AS order_date,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        o.delivery_days,
        o.delivery_delay_days,
        o.approval_hours,
        o.total_payment_value,
        o.payment_count,
        o.max_installments,
        o.credit_card_value,
        o.boleto_value,
        o.voucher_value,
        o.debit_card_value,
        o.item_count,
        o.distinct_product_count,
        o.distinct_seller_count,
        o.total_item_value,
        o.total_freight_value,
        o.review_score
    FROM orders o
    LEFT JOIN customers c ON o.customer_id = c.customer_id
)

SELECT * FROM final