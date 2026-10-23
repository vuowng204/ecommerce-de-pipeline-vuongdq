-- sử dụng kỹ thuật pivot để (chuyển đổi từ dữ liệu dạng dòng sang dạng cột ->> thuận tiện để làm báo cáo tài chính
WITH payments AS (
    SELECT * FROM {{ ref('stg_olist__order_payments') }}
),
pivoted AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment_value,
        COUNT(DISTINCT payment_sequential) AS payment_count,
        MAX(payment_installments) AS max_installments,
        -- Pivot: mỗi loại thanh toán 1 cột
        SUM(CASE WHEN payment_type = 'credit_card' THEN payment_value ELSE 0 END) AS credit_card_value,
        SUM(CASE WHEN payment_type = 'boleto' THEN payment_value ELSE 0 END) AS boleto_value,
        SUM(CASE WHEN payment_type = 'voucher' THEN payment_value ELSE 0 END) AS voucher_value,
        SUM(CASE WHEN payment_type = 'debit_card' THEN payment_value ELSE 0 END) AS debit_card_value
    FROM payments
    GROUP BY order_id
)
SELECT * FROM pivoted