{{
    config(
        materialized='table'
    )
}}

WITH policy_premium AS (
    SELECT
        branch_id,
        branch_name,
        DATE_TRUNC('month', issue_date) AS period_month,
        SUM(premium_amount) AS gross_written_premium,
        COUNT(policy_id) AS policies_written
    FROM {{ ref('int_branch_policies') }}
    GROUP BY branch_id, branch_name, DATE_TRUNC('month', issue_date)
),

incurred_claims AS (
    SELECT
        branch_id,
        branch_name,
        DATE_TRUNC('month', claim_date) AS period_month,
        SUM(claim_amount) AS incurred_claims_amount,
        SUM(settlement_amount) AS paid_claims_amount,
        COUNT(claim_id) AS claims_count
    FROM {{ ref('int_branch_claims') }}
    GROUP BY branch_id, branch_name, DATE_TRUNC('month', claim_date)
),

payments_by_branch AS (
    SELECT
        policies.branch_id,
        policies.branch_name,
        DATE_TRUNC('month', payments.payment_date) AS period_month,
        SUM(payments.amount) AS premium_received
    FROM {{ ref('stg_payments') }} AS payments
    INNER JOIN {{ ref('int_branch_policies') }} AS policies
        ON payments.policy_id = policies.policy_id
    WHERE payments.claim_id IS NULL
    GROUP BY policies.branch_id, policies.branch_name, DATE_TRUNC('month', payments.payment_date)
),

periods AS (
    SELECT branch_id, branch_name, period_month FROM policy_premium
    UNION
    SELECT branch_id, branch_name, period_month FROM incurred_claims
    UNION
    SELECT branch_id, branch_name, period_month FROM payments_by_branch
)

SELECT
    prd.branch_id,
    prd.branch_name,
    prd.period_month,
    COALESCE(pp.gross_written_premium, 0) AS gross_written_premium,
    COALESCE(pp.policies_written, 0) AS policies_written,
    COALESCE(pb.premium_received, 0) AS premium_received,
    COALESCE(ic.incurred_claims_amount, 0) AS incurred_claims_amount,
    COALESCE(ic.paid_claims_amount, 0) AS paid_claims_amount,
    COALESCE(ic.claims_count, 0) AS claims_count,
    ROUND(
        COALESCE(ic.incurred_claims_amount, 0)
        / NULLIF(pp.gross_written_premium, 0),
        4
    ) AS loss_ratio
FROM periods prd
LEFT JOIN policy_premium pp
    ON prd.branch_id = pp.branch_id
    AND prd.period_month = pp.period_month
LEFT JOIN incurred_claims ic
    ON prd.branch_id = ic.branch_id
    AND prd.period_month = ic.period_month
LEFT JOIN payments_by_branch pb
    ON prd.branch_id = pb.branch_id
    AND prd.period_month = pb.period_month
