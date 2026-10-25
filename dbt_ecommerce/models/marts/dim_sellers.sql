WITH sellers AS (
    SELECT * FROM {{ ref('stg_olist__sellers') }}
)
SELECT
    {{ dbt_utils.generate_surrogate_key(['seller_id']) }} AS seller_sk,
    seller_id,
    seller_city,
    seller_state,
    seller_zip_code_prefix
FROM sellers