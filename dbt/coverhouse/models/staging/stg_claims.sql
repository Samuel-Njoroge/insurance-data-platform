{{
    config(
        materialized='inceremental'
    )
}}

SELECT
    created_at,
    created_by,
    updated_at,
    updated_by,
    claim_id,
    claim_date,
    amount,
    status,
    policy_id,
    agent_id,
    beneficiary_id,
    branch_id,
    active
FROM claims