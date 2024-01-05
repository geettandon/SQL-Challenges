-- Challenge 5 - Pub Pricing Analysis

-- QUESTIONS

-- 1. How many pubs are located in each country??
SELECT country, 
    COUNT(pub_id) AS num_pubs
FROM pubs
GROUP BY country;

-- Sol1:
| country         | num_pubs |
|-----------------|----------|
| Ireland         | 1        |
| United States   | 1        |
| Spain           | 1        |
| United Kingdom  | 1        |

-- 2. What is the total sales amount for each pub, including the beverage price and quantity sold?
SELECT pub_name,
    SUM(price_per_unit * quantity) AS total_sales_amount,
    SUM(price_per_unit) AS beverage_prices,
    SUM(quantity) AS quantity_sold
FROM sales
INNER JOIN pubs ON sales.pub_id = pubs.pub_id
INNER JOIN beverages ON sales.beverage_id = beverages.beverage_id
GROUP BY pub_name;

-- Sol2:
| pub_name        | total_sales_amount | beverage_prices | quantity_sold |
|-----------------|---------------------|-----------------|---------------|
| The Cheers Bar  | 413.57              | 57.95           | 43            |
| The Red Lion    | 532.66              | 82.95           | 34            |
| La Cerveceria   | 337.72              | 65.95           | 28            |
| The Dubliner    | 308.62              | 55.95           | 38            |

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

-- Sol3:
| pub_name      | avg_rating |
|---------------|------------|
| The Red Lion  | 4.67       |

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

-- Sol4:
| beverage_name | quantity_sold |
|---------------|---------------|
| Guinness      | 55            |
| Mojito        | 30            |
| Chardonnay    | 18            |
| Tequila       | 18            |
| IPA           | 14            |

-- 5. How many sales transactions occurred on each date?
SELECT transaction_date,
    COUNT(sale_id) AS num_of_sales_transactions
FROM sales
GROUP BY transaction_date
ORDER BY transaction_date;

-- Sol5:
| transaction_date | num_of_sales_transactions |
|------------------|---------------------------|
| 2023-05-01       | 3                         |
| 2023-05-02       | 2                         |
| 2023-05-03       | 4                         |
| 2023-05-04       | 1                         |
| 2023-05-06       | 1                         |
| 2023-05-09       | 5                         |
| 2023-05-11       | 2                         |
| 2023-05-12       | 1                         |
| 2023-05-13       | 1                         |

-- 6. Find the name of someone that had cocktails and which pub they had it in.
SELECT customer_name,
    pub_name
FROM ratings
INNER JOIN pubs ON ratings.pub_id = pubs.pub_id
WHERE lower(review) LIKE '%cocktail%';

-- Sol6:
| customer_name | pub_name       |
|---------------|----------------|
| Sophia Davis  | The Cheers Bar |

-- 7. What is the average price per unit for each category of beverages, excluding the category 'Spirit'?
SELECT category,
    ROUND(AVG(price_per_unit), 2) AS avg_price_per_unit
FROM beverages
WHERE category != 'Spirit'
GROUP BY category;

-- Sol7:
| category | avg_price_per_unit |
|----------|--------------------|
| Cocktail | 8.99               |
| Beer     | 5.49               |
| Wine     | 12.99              |
| Whiskey  | 29.99              |

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

-- Sol8:
| pub_name      | rating |
|---------------|--------|
| The Red Lion  | 4.67   |
| La Cerveceria | 4.60   |

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

-- Sol9:
| pub_name       | transaction_date  | running_total_sales_amount  |
|----------------|-------------------|-----------------------------|
| The Red Lion   | 2023-05-01        | 209.85                      |
| The Red Lion   | 2023-05-06        | 254.80                      |
| The Red Lion   | 2023-05-11        | 532.66                      |
| The Dubliner   | 2023-05-01        | 47.92                       |
| The Dubliner   | 2023-05-03        | 101.86                      |
| The Dubliner   | 2023-05-09        | 236.74                      |
| The Dubliner   | 2023-05-12        | 308.62                      |
| The Cheers Bar | 2023-05-02        | 107.88                      |
| The Cheers Bar | 2023-05-03        | 288.66                      |
| The Cheers Bar | 2023-05-09        | 388.62                      |
| The Cheers Bar | 2023-05-13        | 413.57                      |
| La Cerveceria  | 2023-05-02        | 38.97                       |
| La Cerveceria  | 2023-05-03        | 188.91                      |
| La Cerveceria  | 2023-05-04        | 248.81                      |
| La Cerveceria  | 2023-05-09        | 337.72                      |

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

-- Sol10:
| country         | category | avg_price_per_unit | overall_avg_price |
|-----------------|----------|--------------------|-------------------|
| Ireland         | Beer     | 5.66               | 14.88             |
| Ireland         | Cocktail | 8.99               | 14.88             |
| Ireland         | Whiskey  | 29.99              | 14.88             |
| Spain           | Beer     | 5.99               | 13.24             |
| Spain           | Cocktail | 8.99               | 13.24             |
| Spain           | Spirit   | 24.99              | 13.24             |
| Spain           | Wine     | 12.99              | 13.24             |
| United Kingdom  | Beer     | 5.99               | 16.59             |
| United Kingdom  | Cocktail | 8.99               | 16.59             |
| United Kingdom  | Spirit   | 24.99              | 16.59             |
| United Kingdom  | Whiskey  | 29.99              | 16.59             |
| United Kingdom  | Wine     | 12.99              | 16.59             |
| United States   | Beer     | 5.49               | 13.12             |
| United States   | Cocktail | 8.99               | 13.12             |
| United States   | Spirit   | 24.99              | 13.12             |
| United States   | Wine     | 12.99              | 13.12             |

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

-- Sol11:
| pub_name       | category | percentage_contribution_to_sales | overall_sales |
|----------------|----------|----------------------------------|---------------|
| The Red Lion   | Spirit   | 37.53                            | 532.66        |
| The Red Lion   | Whiskey  | 28.15                            | 532.66        |
| The Red Lion   | Wine     | 14.63                            | 532.66        |
| The Red Lion   | Beer     | 11.25                            | 532.66        |
| The Red Lion   | Cocktail | 8.44                             | 532.66        |
| The Cheers Bar | Beer     | 27.76                            | 413.57        |
| The Cheers Bar | Cocktail | 26.09                            | 413.57        |
| The Cheers Bar | Spirit   | 24.17                            | 413.57        |
| The Cheers Bar | Wine     | 21.99                            | 413.57        |
| La Cerveceria  | Spirit   | 44.40                            | 337.72        |
| La Cerveceria  | Wine     | 19.23                            | 337.72        |
| La Cerveceria  | Cocktail | 18.63                            | 337.72        |
| La Cerveceria  | Beer     | 17.74                            | 337.72        |
| The Dubliner   | Beer     | 53.37                            | 308.62        |
| The Dubliner   | Whiskey  | 29.15                            | 308.62        |
| The Dubliner   | Cocktail | 17.48                            | 308.62        |
