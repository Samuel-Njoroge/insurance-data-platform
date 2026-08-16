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
    agents.agent_id,
    agents.agent_name,
    agents.email,
    agents.phone_number,
    agents.hire_date,
    agents.job_id,
    agents.commission_pct,
    agents.manager_id,
    agents.department_id,
    agents.active,
    agent_policies.branch_id,
    agent_policies.branch_name,
    COALESCE(agent_policies.policies_sold, 0) AS policies_sold,
    COALESCE(agent_policies.active_policies_sold, 0) AS active_policies_sold,
    COALESCE(agent_policies.total_premium_sold, 0) AS total_premium_sold,
    agent_policies.avg_premium_per_policy,
    ROUND(
        COALESCE(agent_policies.total_premium_sold, 0) * COALESCE(agents.commission_pct, 0),
        2
    ) AS estimated_commission
FROM agents
LEFT JOIN agent_policies
    ON agents.agent_id = agent_policies.agent_id
