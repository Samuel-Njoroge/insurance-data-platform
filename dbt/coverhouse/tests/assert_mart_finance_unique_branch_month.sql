{{
    config(
        severity='error'
    )
}}

SELECT
    branch_id,
    period_month,
    COUNT(*) AS row_count
FROM {{ ref('mrt_finance') }}
GROUP BY branch_id, period_month
HAVING COUNT(*) > 1
