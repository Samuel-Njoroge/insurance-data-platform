{{
    config(
        materialized='incremenental'
    )
}}

SELECT
    created_at,
    created_by,
    updated_at,
    updated_by,
    payment_id,
    claim_id,
    policy_id,
    payment_date,
    amount,
    method,
    reference,
    active
FROM raw.payments