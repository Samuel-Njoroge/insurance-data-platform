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
    beneficiary_id,
    first_name,
    last_name,
    email,
    phone_number,
    active
FROM beneficiaries