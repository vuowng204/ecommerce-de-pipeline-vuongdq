WITH source AS (
    SELECT * FROM {{ source('olist', 'order_reviews') }}
),

renamed AS (
    SELECT
        TRIM(review_id)::VARCHAR AS review_id,
        TRIM(order_id)::VARCHAR AS order_id,
        {{ safe_cast('review_score', 'INTEGER') }} AS review_score,
        TRIM(review_comment_title)::VARCHAR AS review_comment_title,
        TRIM(review_comment_message)::VARCHAR AS review_comment_message,
        CAST(review_creation_date AS TIMESTAMP) AS review_creation_date,
        CAST(review_answer_timestamp AS TIMESTAMP) AS review_answer_timestamp
    FROM source
    WHERE review_score BETWEEN 1 AND 5
)
SELECT * FROM renamed