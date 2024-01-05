-- Intro
/*
You are a Pricing Analyst working for a pub chain called 'Pubs "R" Us'
You have been tasked with analysing the drinks prices and sales to gain a greater insight into how the pubs in your chain are performing.
*/

-- Questions

-- 1. How many pubs are located in each country??
SELECT country, 
    COUNT(pub_id) AS num_pubs
FROM pubs
GROUP BY country;

-- 2. What is the total sales amount for each pub, including the beverage price and quantity sold?
SELECT pub_name,
    SUM(price_per_unit * quantity) AS total_sales_amount,
    SUM(price_per_unit) AS beverage_prices,
    SUM(quantity) AS quantity_sold
FROM sales
INNER JOIN pubs ON sales.pub_id = pubs.pub_id
INNER JOIN beverages ON sales.beverage_id = beverages.beverage_id
GROUP BY pub_name;

-- 3. Which pub has the highest average rating?
WITH highest_rated_pub AS (
    SELECT pub_id,
        ROUND(CAST(AVG(rating) AS numeric), 2) AS avg_rating
    FROM ratings
    GROUP BY pub_id
    ORDER BY avg_rating DESC
    LIMIT 1
)

SELECT pubs.pub_name,
    avg_rating
FROM pubs
INNER JOIN highest_rated_pub ON pubs.pub_id = highest_rated_pub.pub_id;

-- 4. What are the top 5 beverages by sales quantity across all pubs?
WITH beverages_agg_sales AS (
    SELECT beverage_id,
        SUM(quantity) AS quantity_sold
    FROM sales
    GROUP BY beverage_id
)

SELECT beverage_name,
    quantity_sold
FROM beverages 
INNER JOIN beverages_agg_sales ON beverages.beverage_id = beverages_agg_sales.beverage_id
ORDER BY quantity_sold DESC
LIMIT 5;

-- 5. How many sales transactions occurred on each date?
SELECT transaction_date,
    COUNT(sale_id) AS num_of_sales_transactions
FROM sales
GROUP BY transaction_date
ORDER BY transaction_date;

-- 6. Find the name of someone that had cocktails and which pub they had it in.
SELECT customer_name,
    pub_name
FROM ratings
INNER JOIN pubs ON ratings.pub_id = pubs.pub_id
WHERE lower(review) LIKE '%cocktail%';

-- 7. What is the average price per unit for each category of beverages, excluding the category 'Spirit'?
SELECT category,
    ROUND(AVG(price_per_unit), 2) AS avg_price_per_unit
FROM beverages
WHERE category != 'Spirit'
GROUP BY category;

-- 8. Which pubs have a rating higher than the average rating of all pubs?
WITH highest_rated_pub AS (
    SELECT pub_id,
        ROUND(AVG(rating) :: NUMERIC, 2) AS rating
    FROM ratings
    GROUP BY pub_id
    HAVING AVG(rating) > (SELECT AVG(rating) FROM ratings)
)

SELECT pub_name,
    rating
FROM pubs
INNER JOIN highest_rated_pub ON pubs.pub_id = highest_rated_pub.pub_id;

-- 9. What is the running total of sales amount for each pub, ordered by the transaction date?
WITH pub_sales AS (
    SELECT transaction_date,
        pub_id,
        SUM(quantity * price_per_unit) AS sales_amount
    FROM sales
    INNER JOIN beverages ON sales.beverage_id = beverages.beverage_id
    GROUP BY transaction_date, pub_id
)

SELECT pub_name,
    transaction_date,
    SUM(sales_amount) OVER(PARTITION BY pubs.pub_id ORDER BY transaction_date) AS running_total_sales_amount
FROM pubs
INNER JOIN pub_sales ON pubs.pub_id = pub_sales.pub_id;

-- 10. For each country, what is the average price per unit of beverages in each category, and what is the overall average price per unit of beverages across all categories?
WITH country_wise_beverages AS (
    SELECT country,
        category,
        ROUND(AVG(price_per_unit), 2) AS avg_price_per_unit
    FROM sales
    INNER JOIN pubs ON sales.pub_id = pubs.pub_id
    INNER JOIN beverages ON sales.beverage_id = beverages.beverage_id
    GROUP BY country, category
    ORDER BY country, category
)

SELECT country, 
    category,
    avg_price_per_unit,
    ROUND(AVG(avg_price_per_unit) OVER(PARTITION BY country), 2) AS overall_avg_price
FROM country_wise_beverages;

-- 11. For each pub, what is the percentage contribution of each category of beverages to the total sales amount, and what is the pub's overall sales amount?
WITH pub_category_sales AS (
    SELECT pub_name,
        category,
        SUM(price_per_unit * quantity) AS sales_amount
    FROM sales
    INNER JOIN pubs ON sales.pub_id = pubs.pub_id
    INNER JOIN beverages ON sales.beverage_id = beverages.beverage_id
    GROUP BY pub_name, category
)

SELECT pub_name,
    category,
    ROUND(sales_amount / SUM(sales_amount) OVER(PARTITION BY pub_name) * 100, 2) AS percentage_contribution_to_sales,
    SUM(sales_amount) OVER(PARTITION BY pub_name) AS overall_sales
FROM pub_category_sales
ORDER BY overall_sales DESC, percentage_contribution_to_sales DESC;