{{
    config(
        materialized='table'
    )
}}

WITH agents AS (
    SELECT
        agent_id,
        first_name || ' ' || last_name AS agent_name,
        email,
        phone_number,
        hire_date,
        job_id,
        commission_pct,
        manager_id,
        department_id,
        active
    FROM {{ ref('stg_agents') }}
),

agent_policies AS (
    SELECT
        agent_id,
        branch_id,
        branch_name,
        COUNT(policy_id) AS policies_sold,
        SUM(CASE WHEN policy_status = 'Active' THEN 1 ELSE 0 END) AS active_policies_sold,
        SUM(premium_amount) AS total_premium_sold,
        AVG(premium_amount) AS avg_premium_per_policy
    FROM {{ ref('int_branch_policies') }}
    GROUP BY agent_id, branch_id, branch_name
)

SELECT
    ag.agent_id,
    ag.agent_name,
    ag.email,
    ag.phone_number,
    ag.hire_date,
    ag.job_id,
    ag.commission_pct,
    ag.manager_id,
    ag.department_id,
    ag.active,
    agtp.branch_id,
    agtp.branch_name,
    COALESCE(agtp.policies_sold, 0) AS policies_sold,
    COALESCE(agtp.active_policies_sold, 0) AS active_policies_sold,
    COALESCE(agtp.total_premium_sold, 0) AS total_premium_sold,
    agtp.avg_premium_per_policy,
    ROUND(
        COALESCE(agtp.total_premium_sold, 0) * COALESCE(ag.commission_pct, 0),
        2
    ) AS estimated_commission
FROM agents ag
LEFT JOIN agent_policies agtp
    ON ag.agent_id = agtp.agent_id
