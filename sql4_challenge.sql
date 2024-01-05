-- Challenge 4 - Financial Analysis

-- QUESTIONS

-- Query the customers table
SELECT *
FROM customers;

-- Query the accounts table
SELECT *
FROM accounts;

-- Query the transactions table
SELECT *
FROM transactions;

-- Query the branches table
SELECT *
FROM branches;

-- Questions

-- 1. What are the names of all the customers who live in New York?
SELECT firstname,
    lastname
FROM customers
WHERE city = 'New York';

-- 2. What is the total number of accounts in the Accounts table?
SELECT COUNT(accountid) AS total_number_of_accounts
FROM accounts;

-- 3. What is the total balance of all checking accounts?
SELECT SUM(balance) AS total_balance_of_all_checking_accounts
FROM accounts
WHERE accounttype = 'Checking';

-- 4. What is the total balance of all accounts associated with customers who live in Los Angeles?
SELECT SUM(balance) AS total_balance_of_all_account_of_LA_customers
FROM accounts
WHERE customerid IN (
    SELECT customerid
    FROM customers
    WHERE city = 'Los Angeles'
);

-- 5. Which branch has the highest average account balance?
SELECT *
FROM branches 
WHERE branchid IN (
    SELECT branchid
    FROM accounts
    GROUP BY branchid
    ORDER BY AVG(balance) DESC
    LIMIT 1
);

-- 6. Which customer has the highest current balance in their accounts?
-- Aggregating the transactions table to find activity in each account
WITH account_activity AS (
    SELECT accountid,
        SUM(amount) AS activity
    FROM transactions
    GROUP BY accountid
),

/* Joining the above table to accounts table to sum the balance with debit/credit
and find the customerid of the customer with the highest current balance.*/
highest_balance AS (
    SELECT accounts.customerid,
        SUM(balance + COALESCE(activity, 0)) AS total_balance
    FROM accounts
    LEFT JOIN account_activity ON accounts.accountid = account_activity.accountid
    WHERE accounttype IN ('Checking', 'Savings')
    GROUP BY accounts.customerid
    ORDER BY total_balance DESC
    LIMIT 1
)

-- Joining customers table to find the details of the customer with highest current balance.
SELECT customers.*,
    total_balance
FROM customers
INNER JOIN highest_balance ON customers.customerid = highest_balance.customerid;

-- 7. Which customer has made the most transactions in the Transactions table?
-- Aggregating transactions table to find count of transactions
WITH txn_agg AS (
    SELECT accountid,
        COUNT(transactionid) AS count_txn
    FROM transactions
    GROUP BY accountid
),

-- joining above table to accounts to find each customers transactions
customer_txns AS (
    SELECT accounts.customerid,
        SUM(count_txn) AS num_txns
    FROM accounts
    INNER JOIN txn_agg ON accounts.accountid = txn_agg.accountid
    GROUP BY accounts.customerid
)

-- Query the customers table to find the details of customers with most number of transactions.
SELECT customers.*,
    num_txns
FROM customers
INNER JOIN customer_txns ON customers.customerid = customer_txns.customerid
WHERE num_txns = (
    SELECT MAX(num_txns)
    FROM customer_txns
);

-- 8. Which branch has the highest total balance across all of its accounts?
-- Aggregating accounts table to find total balance per branch.
WITH branch_balances AS(
    SELECT branchid,
        SUM(balance) AS total_balance
    FROM accounts
    GROUP BY branchid
    ORDER BY total_balance DESC
    LIMIT 1
)

-- joining the above cte to the branch table to find the respective branch details.
SELECT branches.*,
    total_balance
FROM branches
INNER JOIN branch_balances ON branches.branchid = branch_balances.branchid;

-- 9. Which customer has the highest total balance across all of their accounts, including savings and checking accounts?
-- aggregating the accounts to table find customerid with aggregated balance.
WITH customer_agg_balance AS (
    SELECT customerid,
        SUM(balance) AS total_balance
    FROM accounts
    GROUP BY customerid
    ORDER BY total_balance DESC
    LIMIT 1
)

-- joining the above cte to the customers table to find the respective customer details.
SELECT customers.*,
    total_balance
FROM customers
INNER JOIN customer_agg_balance ON customers.customerid = customer_agg_balance.customerid;

-- 10. Which branch has the highest number of transactions in the Transactions table?
-- aggregating the transactions table to find the txns per account.
WITH txn_per_account AS (
    SELECT accountid, 
        COUNT(transactionid) AS num_txns
    FROM transactions
    GROUP BY accountid
),

-- joining above cte to accounts to find aggregated txns per branch.
txn_per_branch AS (
    SELECT branchid,
        SUM(num_txns) AS num_txns
    FROM accounts
    INNER JOIN txn_per_account ON accounts.accountid = txn_per_account.accountid
    GROUP BY branchid
)

-- joining above cte with branches to find the respective branch details.
SELECT branches.*,
    num_txns
FROM branches
INNER JOIN txn_per_branch ON branches.branchid = txn_per_branch.branchid
WHERE num_txns IN (
    SELECT MAX(num_txns)
    FROM txn_per_branch
);
