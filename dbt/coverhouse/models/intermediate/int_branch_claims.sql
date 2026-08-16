{{
    config(
        materialized='view'
    )
}}

WITH claims AS (
    SELECT *
    FROM {{ ref('stg_claims') }}
),

policies AS (
    SELECT
        policy_id,
        policy_number,
        type AS product_type
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
    cl.claim_id,
    cl.claim_date,
    cl.policy_id,
    pl.policy_number,
    pl.product_type,
    cl.agent_id,
    cl.beneficiary_id,
    cl.branch_id,
    br.branch_name,
    br.branch_city,
    br.branch_state,
    cl.claim_amount,
    cl.reserve_amount,
    cl.settlement_amount,
    cl.cause_of_loss,
    cl.status AS claim_status,
    cl.active
FROM claims cl
LEFT JOIN policies pl
    ON cl.policy_id = pl.policy_id
LEFT JOIN branches br
    ON cl.branch_id = br.branch_id
