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
    endorsement_type,
    endorsement_date,
    premium_adjustment,
    active
FROM policy_endorsements