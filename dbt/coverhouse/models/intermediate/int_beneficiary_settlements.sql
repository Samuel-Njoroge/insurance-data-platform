{{
    config(
        materialized='view'
    )
}}

WITH settlements AS (
    SELECT *
    FROM {{ ref('stg_claim_settlements') }}
),

claims AS (
    SELECT
        claim_id,
        policy_id,
        beneficiary_id,
        claim_date,
        claim_amount,
        status AS claim_status
    FROM {{ ref('stg_claims') }}
),

beneficiaries AS (
    SELECT
        beneficiary_id,
        first_name || ' ' || last_name AS beneficiary_name,
        email,
        phone_number
    FROM {{ ref('stg_beneficiaries') }}
)

SELECT
    stl.claim_settlement_id,
    stl.claim_id,
    cls.policy_id,
    cl.beneficiary_id,
    bn.beneficiary_name,
    bn.email AS beneficiary_email,
    bn.phone_number AS beneficiary_phone_number,
    cl.claim_date,
    cl.claim_amount,
    cl.claim_status,
    stl.settlement_date,
    stl.settlement_amount,
    stl.method AS settlement_method,
    stl.reference,
    stl.approved_by,
    stl.status AS settlement_status,
    stl.active
FROM settlements stl
LEFT JOIN claims cl
    ON stl.claim_id = cl.claim_id
LEFT JOIN beneficiaries bn
    ON cl.beneficiary_id = bn.beneficiary_id
