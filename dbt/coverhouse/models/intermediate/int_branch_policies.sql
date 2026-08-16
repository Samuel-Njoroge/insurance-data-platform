{{
    config(
        materialized='view'
    )
}}

WITH policies AS (
    SELECT *
    FROM {{ ref('stg_policies') }}
),

branches AS (
    SELECT
        branch_id,
        branch_name,
        city AS branch_city,
        state AS branch_state,
        active AS branch_active
    FROM {{ ref('stg_branches') }}
)

SELECT
    pl.policy_id,
    pl.policy_number,
    pl.customer_id,
    pl.agent_id,
    pl.beneficiary_id,
    pl.branch_id,
    br.branch_name,
    br.branch_city,
    br.branch_state,
    pl.type AS product_type,
    pl.issue_date,
    pl.expiry_date,
    pl.premium_amount,
    pl.sum_assured,
    pl.status AS policy_status,
    pl.active
FROM policies pl
LEFT JOIN branches br
    ON pl.branch_id = br.branch_id
