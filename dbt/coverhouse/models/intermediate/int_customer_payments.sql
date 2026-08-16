{{
    config(
        materialized='view'
    )
}}

WITH payments AS (
    SELECT *
    FROM {{ ref('stg_payments') }}
),

policies AS (
    SELECT
        policy_id,
        policy_number,
        customer_id,
        type AS product_type
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
    pmt.payment_id,
    pmt.payment_date,
    pmt.claim_id,
    pmt.policy_id,
    pl.policy_number,
    pl.product_type,
    pl.customer_id,
    cs.customer_name,
    cs.national_id,
    cs.email AS customer_email,
    cs.phone_number AS customer_phone_number,
    cs.city AS customer_city,
    cs.state AS customer_state,
    pmt.amount,
    pmt.method,
    pmt.reference,
    pmt.active
FROM payments pmt
LEFT JOIN policies pl
    ON pmt.policy_id = pl.policy_id
LEFT JOIN customers cs
    ON pl.customer_id = cs.customer_id
