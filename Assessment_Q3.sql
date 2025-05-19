USE adashi_staging;

SHOW TABLES;

DESCRIBE plans_plan;

DESCRIBE savings_savingsaccount;

WITH account_activity AS (
    -- Investment plans (from plans_plan)
    SELECT 
        id AS plan_id,
        owner_id,
        CASE
            WHEN is_a_fund = 1 THEN 'Mutual Fund'
            WHEN is_managed_portfolio = 1 THEN 'Managed Portfolio'
            WHEN is_regular_savings = 1 THEN 'Regular Savings'
            WHEN is_a_goal = 1 THEN 'Goal Savings'
            ELSE 'Other Investment'
        END AS type,
        GREATEST(
            COALESCE(last_charge_date, '1900-01-01'),
            COALESCE(last_returns_date, '1900-01-01'),
            COALESCE(created_on, '1900-01-01')
        ) AS last_activity_date
    FROM plans_plan
    WHERE is_deleted = 0
      AND is_archived = 0
      /* Removed the incomplete status_id NOT IN condition */
    
    UNION ALL
    
    -- Savings accounts (from savings_savingsaccount)
    SELECT 
        plan_id,
        owner_id,
        'Savings Account' AS type,
        COALESCE(
            transaction_date,
            created_on
        ) AS last_activity_date
    FROM savings_savingsaccount
    WHERE transaction_status = 'success' -- or appropriate status for successful transactions
    /* Removed the verification_status_id condition as it might not be needed */
)

SELECT 
    plan_id,
    owner_id,
    type,
    last_activity_date AS last_transaction_date,
    DATEDIFF(CURRENT_DATE, last_activity_date) AS inactivity_days
FROM account_activity
WHERE DATEDIFF(CURRENT_DATE, last_activity_date) > 365
  AND last_activity_date > '1900-01-01'
ORDER BY inactivity_days DESC;


