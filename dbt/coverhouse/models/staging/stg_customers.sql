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
    customer_id,
    first_name,
    last_name,
    email,
    phone_number,
    address,
    city,
    state,
    zip_code,
    active 
FROM customersSS