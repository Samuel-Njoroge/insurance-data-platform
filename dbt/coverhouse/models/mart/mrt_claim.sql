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
    claims.claim_id,
    claims.claim_date,
    claims.policy_id,
    claims.policy_number,
    claims.product_type,
    claims.agent_id,
    claims.beneficiary_id,
    claims.branch_id,
    branch_claims.branch_name,
    branch_claims.branch_city,
    branch_claims.branch_state,
    claims.customer_id,
    claims.customer_name,
    claims.claim_amount,
    claims.reserve_amount,
    claims.settlement_amount,
    claims.cause_of_loss,
    claims.claim_status,
    COALESCE(settlements.settlement_count, 0) AS settlement_count,
    COALESCE(settlements.total_settled_amount, 0) AS total_settled_amount,
    settlements.last_settlement_date,
    DATE_DIFF('day', claims.claim_date, settlements.last_settlement_date) AS days_to_settle,
    CASE WHEN claims.claim_status = 'Settled' THEN 1 ELSE 0 END AS is_settled,
    ROUND(claims.claim_amount / NULLIF(claims.sum_assured, 0), 4) AS claim_to_sum_assured_ratio
FROM claims
LEFT JOIN branch_claims
    ON claims.claim_id = branch_claims.claim_id
LEFT JOIN settlements
    ON claims.claim_id = settlements.claim_id
