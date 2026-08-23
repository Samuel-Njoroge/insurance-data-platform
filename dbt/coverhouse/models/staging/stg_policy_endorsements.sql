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
    policy_endorsement_id,
    policy_id,
    endorsement_date,
    endorsement_type,
    old_value,
    new_value,
    premium_adjustment,
    approved_by,
    active
FROM raw.policy_endorsements