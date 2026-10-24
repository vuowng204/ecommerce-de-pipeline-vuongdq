WITH customers AS (
    SELECT * FROM {{ ref('stg_olist__customers') }}
),

orders AS (
    SELECT * FROM {{ ref('stg_olist__orders') }}
),

-- Gắn thời gian mua hàng vào từng bản ghi khách hàng/địa chỉ
customer_with_orders AS (
    SELECT
        c.customer_unique_id,
        c.customer_city,
        c.customer_state,
        c.customer_zip_code_prefix,
        o.order_purchase_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id 
            ORDER BY o.order_purchase_timestamp DESC
        ) AS rn
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
),

final AS (
    SELECT
        -- Tạo khóa surrogate key dựa trên customer_unique_id (chuẩn thực thể khách hàng)
        {{ dbt_utils.generate_surrogate_key(['customer_unique_id']) }} AS customer_sk,
        customer_unique_id,
        customer_city,
        customer_state,
        customer_zip_code_prefix
    FROM customer_with_orders
    WHERE rn = 1 -- Chỉ lấy địa chỉ của lần mua hàng gần nhất
)

SELECT * FROM final