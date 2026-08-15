{{
    config(
        materialized='table'
    )
}}

SELECT
    created_at,
    created_by,
    updated_at,
    updated_by,
    product_id,
    product_name,
    product_description,
    product_type,
    min_amount,
    max_amount,
    active
FROM products