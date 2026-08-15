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
    policy_id,
    agent_id,
    beneficiary_id,
    branch_id,
    claim_amount,
    reserve_amount,
    settlement_amount,
    cause_of_loss,
    status,
    active
FROM claims