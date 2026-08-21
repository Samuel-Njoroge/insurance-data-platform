{{
    config(
        severity='error'
    )
}}

SELECT
    claims.claim_id,
    claims.claim_date,
    policies.policy_id,
    policies.issue_date
FROM {{ ref('stg_claims') }} AS claims
INNER JOIN {{ ref('stg_policies') }} AS policies
    ON claims.policy_id = policies.policy_id
WHERE claims.claim_date < policies.issue_date
