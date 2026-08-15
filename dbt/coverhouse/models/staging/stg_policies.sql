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
    policy_id,
    policy_number,
    type,
    issue_date,
    expiry_date,
    premium_amount,
    agent_id,
    beneficiary_id,
    branch_id,
    status,
    sum_assured,
    active
FROM policies
