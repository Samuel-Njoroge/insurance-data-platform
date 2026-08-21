{{
    config(
        severity='error'
    )
}}

WITH settlement_totals AS (
    SELECT
        claim_id,
        SUM(settlement_amount) AS total_settlement_amount
    FROM {{ ref('stg_claim_settlements') }}
    GROUP BY claim_id
)

SELECT
    settlement_totals.claim_id,
    settlement_totals.total_settlement_amount,
    claims.claim_amount
FROM settlement_totals
INNER JOIN {{ ref('stg_claims') }} AS claims
    ON settlement_totals.claim_id = claims.claim_id
WHERE settlement_totals.total_settlement_amount > claims.claim_amount
