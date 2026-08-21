{{
    config(
        severity='error'
    )
}}

SELECT *
FROM {{ ref('stg_payments') }}
WHERE amount IS NULL
   OR amount <= 0
