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
    branch_id,
    branch_name,
    address,
    city,
    state,
    zip_code,
    active
FROM raw.branches