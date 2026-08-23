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
    national_id,
    first_name,
    last_name,
    email,
    phone_number,
    date_of_birth,
    gender,
    address,
    city,
    state,
    zip_code,
    active 
FROM raw.customers