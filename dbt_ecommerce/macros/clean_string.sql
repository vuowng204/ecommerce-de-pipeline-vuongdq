-- Bỏ khoảng trắng từ chuỗi và xử lý lower
{% macro clean_string(column_name) %}
    TRIM(LOWER({{ column_name }}))
{% endmacro %}