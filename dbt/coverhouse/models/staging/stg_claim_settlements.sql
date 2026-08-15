{{
    config(
        materialized='incremental'
    )
}}

SELECT
    created_at,
    created_by,
    updated_at,
    updated_by,
    claim_settlement_id,
    claim_id,
    settlement_amount,
    settlement_date,
    method,
    reference,
    approved_by,
    status,
    active
FROM claim_settlements
