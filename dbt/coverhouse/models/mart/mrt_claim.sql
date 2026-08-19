{{
    config(
        materialized='table'
    )
}}

WITH claims AS (
    SELECT *
    FROM {{ ref('int_customer_claims') }}
),

branch_claims AS (
    SELECT
        claim_id,
        branch_name,
        branch_city,
        branch_state
    FROM {{ ref('int_branch_claims') }}
),

settlements AS (
    SELECT
        claim_id,
        COUNT(claim_settlement_id) AS settlement_count,
        SUM(settlement_amount) AS total_settled_amount,
        MAX(settlement_date) AS last_settlement_date
    FROM {{ ref('int_beneficiary_settlements') }}
    GROUP BY claim_id
)

SELECT
    cl.claim_id,
    cl.claim_date,
    cl.policy_id,
    cl.policy_number,
    cl.product_type,
    cl.agent_id,
    cl.beneficiary_id,
    cl.branch_id,
    brcl.branch_name,
    brcl.branch_city,
    brcl.branch_state,
    cl.customer_id,
    cl.customer_name,
    cl.claim_amount,
    cl.reserve_amount,
    cl.settlement_amount,
    cl.cause_of_loss,
    cl.claim_status,
    COALESCE(stl.settlement_count, 0) AS settlement_count,
    COALESCE(stl.total_settled_amount, 0) AS total_settled_amount,
    stl.last_settlement_date,
    DATE_DIFF('day', cl.claim_date, stl.last_settlement_date) AS days_to_settle,
    CASE WHEN cl.claim_status = 'Settled' THEN 1 ELSE 0 END AS is_settled,
    ROUND(cl.claim_amount / NULLIF(cl.sum_assured, 0), 4) AS claim_to_sum_assured_ratio
FROM claims cl
LEFT JOIN branch_claims brcl
    ON cl.claim_id = brcl.claim_id
LEFT JOIN settlements stl
    ON cl.claim_id = stl.claim_id
