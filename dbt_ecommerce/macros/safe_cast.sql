-- Xử lý trường hợp cột có giá trị rỗng '' hoặc khoảng trắng — PostgreSQL sẽ lỗi khi CAST '' sang số.
{% macro safe_cast(column_name, data_type) %}
    CAST(NULLIF(TRIM(CAST({{ column_name }} AS VARCHAR)), '') AS {{ data_type }})
{% endmacro %}