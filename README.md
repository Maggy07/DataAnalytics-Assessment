**Customer Data Analysis Project**
---
**Task 1: Customers with Funded Savings & Investment Plans**

**Objective**: Identify customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.

**Approach:**

Used conditional aggregation (CASE WHEN) to count savings vs. investment plans separately.

Joined users_customuser and plans_plan tables, filtering for active, funded plans.

Sorted results by total_deposits DESC to prioritize high-value customers.

**Challenges:**

NULL Handling: Used COALESCE for customer names to avoid concatenation issues.

Plan Type Logic: Distinguished savings (is_regular_savings) vs. investments (is_a_fund or is_managed_portfolio).

---
**Task 2: Transaction Frequency Analysis**

**Objective:** Segment customers by transaction frequency (High/Medium/Low) based on monthly averages.

**Approach:**

Grouped transactions by customer and month (YYYY-MM format).

Calculated average monthly transactions, then categorized:

High: ≥10/month

Medium: 3-9/month

Low: ≤2/month

Ordered results logically (High → Low) using a custom CASE in ORDER BY.

**Challenges:**

Dynamic Month Grouping: Used DATE_FORMAT to standardize periods.

**Edge Cases**: Explicitly filtered transaction_status = 'success' for accuracy.

---
**Task 3: Account Inactivity Alert**

**Objective**: Flag accounts with no transactions for >365 days.

**Approach:**

Combined savings (savings_savingsaccount) and investment (plans_plan) data with UNION ALL.

Determined last_activity_date using GREATEST() for investment plans (multiple date fields).

Filtered for inactivity (DATEDIFF > 365) and excluded placeholder dates.

**Challenges:**

**Date Logic**: Handled NULLs with COALESCE and fallback dates.

**Mixed Data Sources**: Unified schemas with a type column for clarity.

---
**Task 4: Customer Lifetime Value (CLV) Estimation**

**Objective:** Estimate CLV based on tenure, transaction volume, and 0.1% profit assumption.

**Approach:**

Calculated tenure (TIMESTAMPDIFF in months) and total transactions.

**Derived CLV:**

CLV = (total_transactions / tenure) * 12 * (total_profit / total_transactions)

Safeguarded against division by zero with CASE WHEN.

**Challenges:**

New Customers: Used LEFT JOIN to include those with no transactions (CLV=0).

Profit Model: Explicitly defined profit as 0.1% of transaction value.

