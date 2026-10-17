-- =====================================================
-- Olist Brazilian E-commerce — TYPED SCHEMA WITH FKs
-- Mô phỏng hệ thống OLTP thực tế
-- =====================================================



-- 1. Bảng Translation (Phải tạo đầu tiên vì Products tham chiếu tới)
CREATE TABLE IF NOT EXISTS product_category_name_translation (
    product_category_name         VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100) NOT NULL
);

-- 2. Bảng Customers
CREATE TABLE IF NOT EXISTS customers (
    customer_id              VARCHAR(50) PRIMARY KEY,
    customer_unique_id       VARCHAR(50) NOT NULL,
    customer_zip_code_prefix VARCHAR(10),
    customer_city            VARCHAR(100),
    customer_state           VARCHAR(10)
);

-- 3. Bảng Sellers
CREATE TABLE IF NOT EXISTS sellers (
    seller_id              VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(10),
    seller_city            VARCHAR(100),
    seller_state           VARCHAR(10)
);

-- 4. Bảng Geolocation (Không có PK vì 1 zip code có nhiều lat/lng)
CREATE TABLE IF NOT EXISTS geolocation (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat             NUMERIC(10, 6),
    geolocation_lng             NUMERIC(10, 6),
    geolocation_city            VARCHAR(100),
    geolocation_state           VARCHAR(10)
);
CREATE INDEX IF NOT EXISTS idx_geo_zip ON geolocation(geolocation_zip_code_prefix);

-- 5. Bảng Products
CREATE TABLE IF NOT EXISTS products (
    product_id                 VARCHAR(50) PRIMARY KEY,
    -- Cho phép NULL vì có sản phẩm không có category
    product_category_name      VARCHAR(100) REFERENCES product_category_name_translation(product_category_name),
    product_name_lenght        INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty         INTEGER,
    product_weight_g           NUMERIC(10, 2),
    product_length_cm          NUMERIC(10, 2),
    product_height_cm          NUMERIC(10, 2),
    product_width_cm           NUMERIC(10, 2)
);

-- 6. Bảng Orders
CREATE TABLE IF NOT EXISTS orders (
    order_id                      VARCHAR(50) PRIMARY KEY,
    customer_id                   VARCHAR(50) NOT NULL REFERENCES customers(customer_id),
    order_status                  VARCHAR(30) NOT NULL,
    order_purchase_timestamp      TIMESTAMP,
    order_approved_at             TIMESTAMP,
    order_delivered_carrier_date  TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- 7. Bảng Order Items
CREATE TABLE IF NOT EXISTS order_items (
    order_id            VARCHAR(50) REFERENCES orders(order_id),
    order_item_id       INTEGER,
    product_id          VARCHAR(50) REFERENCES products(product_id),
    seller_id           VARCHAR(50) REFERENCES sellers(seller_id),
    shipping_limit_date TIMESTAMP,
    price               NUMERIC(10, 2),
    freight_value       NUMERIC(10, 2),
    PRIMARY KEY (order_id, order_item_id)
);

-- 8. Bảng Order Payments
CREATE TABLE IF NOT EXISTS order_payments (
    order_id             VARCHAR(50) REFERENCES orders(order_id),
    payment_sequential   INTEGER,
    payment_type         VARCHAR(30),
    payment_installments INTEGER,
    payment_value        NUMERIC(10, 2),
    PRIMARY KEY (order_id, payment_sequential)
);

-- 9. Bảng Order Reviews
CREATE TABLE IF NOT EXISTS order_reviews (
    review_id               VARCHAR(50) NOT NULL,
    order_id                VARCHAR(50) NOT NULL REFERENCES orders(order_id),
    review_score            INTEGER,
    review_comment_title    TEXT,
    review_comment_message  TEXT,
    review_creation_date    TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    PRIMARY KEY (review_id, order_id)
);