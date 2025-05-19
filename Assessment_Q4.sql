USE adashi_staging;

SHOW TABLES;

DESCRIBE users_customuser;

DESCRIBE savings_savingsaccount;

WITH customer_transactions AS (
    -- Calculate transaction metrics for each customer
    SELECT
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', COALESCE(u.last_name, '')) AS name,
        TIMESTAMPDIFF(MONTH, u.created_on, CURRENT_DATE()) AS tenure_months,
        COUNT(sa.id) AS total_transactions,
        COALESCE(SUM(sa.amount), 0) AS total_transaction_value,
        COALESCE(SUM(sa.amount), 0) * 0.001 AS total_profit  -- 0.1% profit per transaction
    FROM
        users_customuser u
    LEFT JOIN savings_savingsaccount sa ON u.id = sa.owner_id
    WHERE
        sa.transaction_status = 'success'  -- Only count successful transactions
    GROUP BY
        u.id, u.first_name, u.last_name, u.created_on
)

SELECT
    customer_id,
    name,
    tenure_months,
    total_transactions,
    -- Calculate CLV: (total_transactions/tenure) * 12 * avg_profit_per_transaction
    CASE
        WHEN tenure_months > 0 AND total_transactions > 0 
        THEN (total_transactions/tenure_months) * 12 * (total_profit/total_transactions)
        ELSE 0
    END AS estimated_clv
FROM
    customer_transactions
ORDER BY
    estimated_clv DESC;