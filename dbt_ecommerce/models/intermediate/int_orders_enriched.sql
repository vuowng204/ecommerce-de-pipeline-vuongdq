WITH orders AS (
    SELECT * FROM {{ ref('stg_olist__orders') }}
),
payments AS (
    SELECT * FROM {{ ref('int_payments_pivoted_to_orders') }}
),
reviews AS (
    SELECT
        order_id,
        AVG(review_score) AS review_score,
        COUNT(review_id) AS review_count
    FROM {{ ref('stg_olist__order_reviews') }}
    GROUP BY order_id
),
items_agg AS (
    SELECT
        order_id,
        COUNT(*) AS item_count,
        COUNT(DISTINCT product_id) AS distinct_product_count,
        COUNT(DISTINCT seller_id) AS distinct_seller_count,
        SUM(price) AS total_item_value,
        SUM(freight_value) AS total_freight_value
    FROM {{ ref('stg_olist__order_items') }}
    GROUP BY order_id
),
joined AS (
    SELECT 
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,

        EXTRACT(EPOCH FROM (o.order_delivered_customer_date -o.order_purchase_timestamp))/86400.0 AS delivery_days,
        EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_estimated_delivery_date)) / 86400.0 AS delivery_delay_days,
        EXTRACT(EPOCH FROM (o.order_approved_at - o.order_purchase_timestamp)) / 3600.0 AS approval_hours,

        -- payments
        COALESCE(p.total_payment_value, 0) AS total_payment_value,
        COALESCE(p.payment_count, 0) AS payment_count,
        COALESCE(p.max_installments, 0) AS max_installments,
        COALESCE(p.credit_card_value, 0) AS credit_card_value,
        COALESCE(p.boleto_value, 0) AS boleto_value,
        COALESCE(p.voucher_value, 0) AS voucher_value,
        COALESCE(p.debit_card_value, 0) AS debit_card_value,
    
     -- Items
        COALESCE(i.item_count, 0) AS item_count,
        COALESCE(i.distinct_product_count, 0) AS distinct_product_count,
        COALESCE(i.distinct_seller_count, 0) AS distinct_seller_count,
        COALESCE(i.total_item_value, 0) AS total_item_value,
        COALESCE(i.total_freight_value, 0) AS total_freight_value,
         -- Reviews
        COALESCE(r.review_score, NULL) AS review_score,
        COALESCE(r.review_count, 0) AS review_count
    FROM orders AS o
    LEFT JOIN payments AS p ON p.order_id = o.order_id
    LEFT JOIN items_agg AS i ON i.order_id = o.order_id
    LEFT JOIN reviews AS r ON r.order_id = o.order_id
    LIMIT 100
)
SELECT * FROM joined