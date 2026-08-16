{{
    config(
        materialized='table'
    )
}}

WITH customers AS (
    SELECT
        customer_id,
        national_id,
        first_name || ' ' || last_name AS customer_name,
        email,
        phone_number,
        date_of_birth,
        gender,
        city,
        state,
        active
    FROM {{ ref('stg_customers') }}
),

policies AS (
    SELECT
        customer_id,
        COUNT(policy_id) AS policy_count,
        SUM(CASE WHEN policy_status = 'Active' THEN 1 ELSE 0 END) AS active_policy_count,
        SUM(premium_amount) AS total_premium,
        SUM(sum_assured) AS total_sum_assured,
        MIN(issue_date) AS first_policy_date,
        MAX(issue_date) AS last_policy_date
    FROM {{ ref('int_branch_policies') }}
    GROUP BY customer_id
),

claims AS (
    SELECT
        customer_id,
        COUNT(claim_id) AS claim_count,
        SUM(claim_amount) AS total_claim_amount,
        SUM(settlement_amount) AS total_settlement_amount
    FROM {{ ref('int_customer_claims') }}
    GROUP BY customer_id
),

payments AS (
    SELECT
        customer_id,
        COUNT(payment_id) AS payment_count,
        SUM(amount) AS total_payments
    FROM {{ ref('int_customer_payments') }}
    GROUP BY customer_id
)

SELECT
    customers.customer_id,
    customers.national_id,
    customers.customer_name,
    customers.email,
    customers.phone_number,
    customers.date_of_birth,
    customers.gender,
    customers.city,
    customers.state,
    customers.active,
    COALESCE(policies.policy_count, 0) AS policy_count,
    COALESCE(policies.active_policy_count, 0) AS active_policy_count,
    COALESCE(policies.total_premium, 0) AS total_premium,
    COALESCE(policies.total_sum_assured, 0) AS total_sum_assured,
    policies.first_policy_date,
    policies.last_policy_date,
    COALESCE(claims.claim_count, 0) AS claim_count,
    COALESCE(claims.total_claim_amount, 0) AS total_claim_amount,
    COALESCE(claims.total_settlement_amount, 0) AS total_settlement_amount,
    COALESCE(payments.payment_count, 0) AS payment_count,
    COALESCE(payments.total_payments, 0) AS total_payments
FROM customers
LEFT JOIN policies
    ON customers.customer_id = policies.customer_id
LEFT JOIN claims
    ON customers.customer_id = claims.customer_id
LEFT JOIN payments
    ON customers.customer_id = payments.customer_id
