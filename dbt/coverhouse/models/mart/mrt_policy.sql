{{
    config(
        materialized='table'
    )
}}

WITH policies AS (
    SELECT *
    FROM {{ ref('int_branch_policies') }}
)

SELECT
    policy_id,
    policy_number,
    customer_id,
    agent_id,
    beneficiary_id,
    branch_id,
    branch_name,
    branch_city,
    branch_state,
    product_type,
    issue_date,
    expiry_date,
    premium_amount,
    sum_assured,
    policy_status,
    active,
    CASE WHEN policy_status = 'Active' THEN 1 ELSE 0 END AS is_active_policy,
    CASE WHEN expiry_date < CURRENT_DATE THEN 1 ELSE 0 END AS is_expired,
    DATE_DIFF('day', issue_date, COALESCE(expiry_date, CURRENT_DATE)) AS policy_term_days,
    DATE_TRUNC('month', issue_date) AS issue_month
FROM policies
