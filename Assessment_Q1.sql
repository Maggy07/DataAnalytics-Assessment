USE adashi_staging;

SHOW TABLES;

DESCRIBE plans_plan;

SELECT * FROM plans_plan
LIMIT 10;

SELECT * FROM savings_savingsaccount
LIMIT 10;

SELECT 
    *
FROM
    users_customuser
LIMIT 10;

WITH customer_plans AS (
    SELECT
        u.id AS owner_id,
        CONCAT(u.first_name, ' ', COALESCE(u.last_name, '')) AS name,
        COUNT(DISTINCT CASE WHEN pp.is_regular_savings = 1 THEN pp.id END) AS savings_count,
        COUNT(DISTINCT CASE WHEN pp.is_a_fund = 1 OR pp.is_managed_portfolio = 1 THEN pp.id END) AS investment_count,
        COALESCE(SUM(pp.amount), 0) AS total_deposits
    FROM
        users_customuser u
    JOIN plans_plan pp ON u.id = pp.owner_id 
        AND pp.amount > 0 
        AND pp.is_deleted = 0
    GROUP BY
        u.id, u.first_name, u.last_name
)

SELECT
    owner_id,
    name,
    savings_count,
    investment_count,
    total_deposits
FROM
    customer_plans
WHERE
    savings_count >= 1 
    AND investment_count >= 1
ORDER BY
    total_deposits DESC;



