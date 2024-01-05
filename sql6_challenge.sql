-- Challenge 6 - Marketing Analysis

-- QUESTIONS

-- 1. How many transactions were completed during each marketing campaign?
SELECT campaign_id,
    campaign_name,
    COUNT(transaction_id) AS num_txns
FROM marketing_campaigns AS M
INNER JOIN transactions AS T ON T.purchase_date BETWEEN M.start_date AND M.end_date
GROUP BY campaign_id
ORDER BY campaign_id ASC;

-- Sol1:
| campaign_id | campaign_name          | num_txns |
|-------------|------------------------|----------|
| 1           | Summer Sale            | 13       |
| 2           | New Collection Launch  | 9        |
| 3           | Super Save             | 8        |

-- 2. Which product had the highest sales quantity?
SELECT S.product_id,
    S.product_name,
    SUM(quantity) AS sales_quantity
FROM transactions AS T
INNER JOIN sustainable_clothing AS S ON T.product_id = S.product_id
GROUP BY S.product_id, S.product_name
ORDER BY sales_quantity DESC
LIMIT 1;

-- Sol2:
| product_id | product_name            | sales_quantity |
|------------|-------------------------|-----------------|
| 12         | Organic Cotton Sweater | 9               |

-- 3. What is the total revenue generated from each marketing campaign?
SELECT campaign_id,
    campaign_name,
    ROUND(CAST(SUM(S.price * quantity) AS NUMERIC), 2) AS total_revenue_generated
FROM marketing_campaigns AS M
INNER JOIN transactions AS T ON T.purchase_date BETWEEN M.start_date AND M.end_date
INNER JOIN sustainable_clothing AS S ON T.product_id = S.product_id
GROUP BY campaign_id, campaign_name
ORDER BY campaign_id ASC;

-- Sol3:
| campaign_id | campaign_name          | total_revenue_generated |
|-------------|------------------------|-------------------------|
| 1           | Summer Sale            | 1044.82                 |
| 2           | New Collection Launch  | 499.89                  |
| 3           | Super Save             | 529.89                 |

-- 4. What is the top-selling product category based on the total revenue generated?
SELECT category,
    SUM(price * quantity) AS total_revenue_generated
FROM sustainable_clothing AS S 
INNER JOIN transactions AS T ON S.product_id = T.product_id
GROUP BY category
ORDER BY total_revenue_generated DESC
LIMIT 1;

-- Sol4:
| category | total_revenue_generated |
|----------|-------------------------|
| Bottoms  | 1289.79                 |

-- 5. Which products had a higher quantity sold compared to the average quantity sold?
SELECT product_name,
    SUM(quantity) AS quantity_sold
FROM sustainable_clothing AS S 
INNER JOIN transactions AS T ON S.product_id = T.product_id
GROUP BY product_name
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM transactions)
ORDER BY quantity_sold DESC;

-- Sol5:
| product_name                | quantity_sold |
|-----------------------------|---------------|
| Organic Cotton Sweater      | 9             |
| Bamboo Yoga Leggings        | 8             |
| Recycled Denim Jeans        | 8             |
| Linen Jumpsuit              | 7             |
| Organic Cotton Socks        | 7             |
| Bamboo Lounge Pants         | 5             |
| Hemp Baseball Cap           | 5             |
| Organic Cotton Skirt        | 5             |
| Eco-Friendly Hoodie         | 5             |
| Cork Sandals                | 4             |
| Recycled Polyester Jacket   | 4             |
| Linen Button-Down Shirt     | 3             |
| Upcycled Denim Jacket       | 3             |
| Hemp Overalls               | 3             |
| Organic Cotton Dress        | 3             |
| Recycled Nylon Backpack     | 2             |
| Sustainable Swim Shorts     | 2             |
| Organic Cotton T-Shirt      | 2             |
| Bamboo Bathrobe             | 2             |

-- 6. What is the average revenue generated per day during the marketing campaigns?
WITH revenue_during_campaigns AS (
    SELECT purchase_date,
        SUM(price * quantity) AS revenue_generated
    FROM marketing_campaigns AS M
    INNER JOIN transactions AS T ON T.purchase_date BETWEEN M.start_date AND M.end_date
    INNER JOIN sustainable_clothing AS S ON T.product_id = S.product_id
    GROUP BY purchase_date
)

SELECT AVG(revenue_generated) AS avg_revenue_generated_during_marketing_campaigns
FROM revenue_during_campaigns;

-- Sol6:
| avg_revenue_generated_during_marketing_campaigns |
|--------------------------------------------------|
| 90.2                                             |

-- 7. What is the percentage contribution of each product to the total revenue?
WITH sales_revenue AS (
    SELECT product_name,
        price * quantity AS revenue
    FROM transactions AS T
    INNER JOIN sustainable_clothing AS S ON T.product_id = S.product_id
)

SELECT product_name,
    ROUND((SUM(revenue) / (SELECT SUM(revenue) FROM sales_revenue)) :: NUMERIC * 100, 2) AS percent_contribution_to_total_revenue
FROM sales_revenue
GROUP BY product_name
ORDER BY percent_contribution_to_total_revenue DESC;

-- Sol7:
| product_name               | percent_contribution_to_total_revenue |
|----------------------------|---------------------------------------|
| Recycled Denim Jeans       | 13.71                                 |
| Linen Jumpsuit             | 10.49                                 |
| Organic Cotton Sweater     | 9.64                                  |
| Bamboo Yoga Leggings       | 9.42                                  |
| Recycled Polyester Jacket  | 7.71                                  |
| Eco-Friendly Hoodie        | 6.42                                  |
| Bamboo Lounge Pants        | 5.35                                  |
| Upcycled Denim Jacket      | 5.14                                  |
| Hemp Overalls              | 4.82                                  |
| Organic Cotton Dress       | 4.50                                  |
| Organic Cotton Skirt       | 3.75                                  |
| Cork Sandals               | 3.43                                  |
| Bamboo Bathrobe            | 3.00                                  |
| Hemp Baseball Cap          | 2.68                                  |
| Linen Button-Down Shirt    | 2.57                                  |
| Recycled Nylon Backpack    | 2.57                                  |
| Sustainable Swim Shorts    | 1.50                                  |
| Organic Cotton Socks       | 1.50                                  |
| Organic Cotton T-Shirt     | 1.28                                  |
| Hemp Crop Top              | 0.54                                  |

-- 8. Compare the average quantity sold during marketing campaigns to outside the marketing campaigns.
WITH marketing_campaigns_qty_sold AS (
    SELECT purchase_date,
        SUM(quantity) AS quantity
    FROM marketing_campaigns AS M
    INNER JOIN transactions AS T ON T.purchase_date BETWEEN M.start_date AND M.end_date
    GROUP BY purchase_date
),

normal_days_qty_sold AS (
    SELECT purchase_date,
        SUM(quantity) AS quantity
    FROM transactions
    WHERE purchase_date NOT IN (SELECT purchase_date FROM marketing_campaigns_qty_sold)
    GROUP BY purchase_date
)

SELECT ROUND(AVG(quantity), 2) AS avg_qty_sold_during_marketing_campaigns,
    (SELECT ROUND(AVG(quantity), 2) AS avg_qty_sold_outside_marketing_campaigns FROM normal_days_qty_sold)
FROM marketing_campaigns_qty_sold;

-- Sol8:
| avg_qty_sold_during_marketing_campaigns | avg_qty_sold_outside_marketing_campaigns  |
|-----------------------------------------|-------------------------------------------|
| 1.74                                    | 2.53                                      |

-- 9. Compare the revenue generated by products inside the marketing campaigns to outside the campaigns.
WITH marketing_campaigns_revenue AS (
    SELECT purchase_date,
        SUM(price * quantity) AS revenue
    FROM marketing_campaigns AS M
    INNER JOIN transactions AS T ON T.purchase_date BETWEEN M.start_date AND M.end_date
    INNER JOIN sustainable_clothing AS S ON T.product_id = S.product_id
    GROUP BY purchase_date
),

normal_days_revenue AS (
    SELECT purchase_date,
        SUM(price * quantity) AS revenue
    FROM transactions AS T
    INNER JOIN sustainable_clothing AS S ON T.product_id = S.product_id
    WHERE purchase_date NOT IN (SELECT purchase_date FROM marketing_campaigns_revenue)
    GROUP BY purchase_date
)

SELECT ROUND(SUM(revenue) :: NUMERIC, 2) AS revenue_during_marketing_campaigns,
    (SELECT ROUND(SUM(revenue):: NUMERIC, 2) AS revenue_outside_marketing_campaigns FROM normal_days_revenue)
FROM marketing_campaigns_revenue;

-- Sol9:
| revenue_during_marketing_campaigns  | revenue_outside_marketing_campaigns  |
|-------------------------------------|--------------------------------------|
| 2074.60                             | 2594.52                              |

-- 10. Rank the products by their average daily quantity sold
WITH daily_qty_sold_per_product AS (
    SELECT product_name,
        purchase_date,
        SUM(quantity) AS qty_sold
    FROM sustainable_clothing AS S
    INNER JOIN transactions AS T ON S.product_id = T.product_id
    GROUP BY product_name, purchase_date
)

SELECT product_name,
    ROUND(AVG(qty_sold), 2) AS avg_daily_qty_sold,
    DENSE_RANK() OVER(ORDER BY AVG(qty_sold) DESC) AS rank
FROM daily_qty_sold_per_product
GROUP BY product_name;

-- Sol10:
| product_name               | avg_daily_qty_sold | rank |
|----------------------------|--------------------|------|
| Sustainable Swim Shorts    | 2.00               | 1    |
| Organic Cotton Sweater     | 1.80               | 2    |
| Linen Jumpsuit             | 1.75               | 3    |
| Organic Cotton Socks       | 1.75               | 3    |
| Organic Cotton Skirt       | 1.67               | 4    |
| Eco-Friendly Hoodie        | 1.67               | 4    |
| Linen Button-Down Shirt    | 1.50               | 5    |
| Upcycled Denim Jacket      | 1.50               | 5    |
| Hemp Overalls              | 1.50               | 5    |
| Recycled Polyester Jacket  | 1.33               | 6    |
| Bamboo Yoga Leggings       | 1.33               | 6    |
| Hemp Baseball Cap          | 1.25               | 7    |
| Bamboo Lounge Pants        | 1.25               | 7    |
| Recycled Denim Jeans       | 1.14               | 8    |
| Cork Sandals               | 1.00               | 9    |
| Hemp Crop Top              | 1.00               | 9    |
| Organic Cotton Dress       | 1.00               | 9    |
| Bamboo Bathrobe            | 1.00               | 9    |
| Recycled Nylon Backpack    | 1.00               | 9    |
| Organic Cotton T-Shirt     | 1.00               | 9    |
