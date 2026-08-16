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
        customer_id,
        type AS product_type,
        premium_amount,
        sum_assured
    FROM {{ ref('stg_policies') }}
),

customers AS (
    SELECT
        customer_id,
        national_id,
        first_name || ' ' || last_name AS customer_name,
        email,
        phone_number,
        city,
        state
    FROM {{ ref('stg_customers') }}
)

SELECT
    cl.claim_id,
    cl.claim_date,
    cl.policy_id,
    pl.policy_number,
    pl.product_type,
    pl.premium_amount,
    pl.sum_assured,
    cl.agent_id,
    cl.beneficiary_id,
    cl.branch_id,
    pl.customer_id,
    cs.customer_name,
    cs.national_id,
    cs.email AS customer_email,
    cs.phone_number AS customer_phone_number,
    cs.city AS customer_city,
    cs.state AS customer_state,
    cl.claim_amount,
    cl.reserve_amount,
    cl.settlement_amount,
    cl.cause_of_loss,
    cl.status AS claim_status,
    cl.active
FROM claims cl
LEFT JOIN policies pl
    ON cl.policy_id = pl.policy_id
LEFT JOIN customers cs
    ON pl.customer_id = cs.customer_id
