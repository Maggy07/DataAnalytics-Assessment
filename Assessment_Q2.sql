USE adashi_staging;

SHOW TABLES;

DESCRIBE plans_plan;


WITH monthly_transactions AS (
    SELECT
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', COALESCE(u.last_name, '')) AS customer_name,
        DATE_FORMAT(sa.transaction_date, '%Y-%m') AS month,
        COUNT(*) AS transaction_count
    FROM
        users_customuser u
    JOIN savings_savingsaccount sa ON u.id = sa.owner_id
    WHERE
        sa.transaction_date IS NOT NULL
    GROUP BY
        u.id, u.first_name, u.last_name, DATE_FORMAT(sa.transaction_date, '%Y-%m')
),

customer_avg_transactions AS (
    SELECT
        customer_id,
        customer_name,
        AVG(transaction_count) AS avg_transactions_per_month
    FROM
        monthly_transactions
    GROUP BY
        customer_id, customer_name
)

SELECT
    CASE
        WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
        WHEN avg_transactions_per_month >= 3 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM
    customer_avg_transactions
GROUP BY
    frequency_category
ORDER BY
    CASE
        WHEN frequency_category = 'High Frequency' THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        ELSE 3
    END;