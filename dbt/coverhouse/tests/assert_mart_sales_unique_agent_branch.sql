{{
    config(
        severity='error'
    )
}}

SELECT
    agent_id,
    branch_id,
    COUNT(*) AS row_count
FROM {{ ref('mrt_sales') }}
GROUP BY agent_id, branch_id
HAVING COUNT(*) > 1
