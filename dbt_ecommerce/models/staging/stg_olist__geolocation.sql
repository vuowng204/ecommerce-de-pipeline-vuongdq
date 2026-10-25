WITH source AS (
    SELECT * FROM {{ source('olist', 'geolocation') }}
),

renamed AS (
    SELECT
        {{ clean_string('geolocation_zip_code_prefix') }} AS geolocation_zip_code_prefix,
        {{ safe_cast('geolocation_lat', 'NUMERIC(10,6)') }} AS geolocation_lat,
        {{ safe_cast('geolocation_lng', 'NUMERIC(10,6)') }} AS geolocation_lng,
        {{ clean_string('geolocation_city') }} AS geolocation_city,     -- Bỏ dấu nháy đơn để macro hiểu đây là tên cột
        {{ clean_string('geolocation_state') }} AS geolocation_state   -- Bỏ dấu nháy đơn để macro hiểu đây là tên cột
    FROM source
)

SELECT * FROM renamed