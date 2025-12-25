USE MASTER;
USE COLLAGE_PROJECT;
GO

SELECT 
    c.customer_id,
    c.customer_key,
    c.first_name,
    c.last_name,
    c.country,
    c.gender,
    c.marital_status
FROM gold.dim_customers c
WHERE c.customer_id IN (
    SELECT TOP 10
        customer_id
    FROM gold.fact_sales
    GROUP BY customer_id
    ORDER BY SUM(price) DESC
);

SELECT 
    order_number,
    customer_id,
    product_id,
    order_date,
    ship_date,
    sales_amount,
    quantity,
    price
FROM gold.fact_sales
WHERE order_date >= DATEADD(YEAR, -1, GETDATE())
ORDER BY order_date DESC;

SELECT 
    customer_id,
    COUNT(order_number) AS number_of_orders
FROM gold.fact_sales
GROUP BY customer_id
HAVING COUNT(order_number) > 1
ORDER BY number_of_orders DESC;

SELECT 
    AVG(DATEDIFF(YEAR, birth_date, GETDATE())) AS average_age
FROM gold.dim_customers
WHERE birth_date IS NOT NULL;

SELECT
    c.gender,
    SUM(s.price) AS total_sales,
    COUNT(DISTINCT s.customer_id) AS customer_count,
    AVG(s.price) AS average_order_value
FROM gold.fact_sales s
INNER JOIN gold.dim_customers c
    ON s.customer_id = c.customer_id
WHERE c.gender IN ('Female', 'Male')
GROUP BY c.gender
ORDER BY total_sales DESC;

SELECT TOP 10
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    COUNT(s.order_number) AS order_count
FROM gold.dim_product p
INNER JOIN gold.fact_sales s
    ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, p.category, p.subcategory
ORDER BY order_count DESC;

SELECT TOP 10
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    p.product_line,
    SUM(s.price) AS total_revenue,
    SUM(s.quantity) AS total_quantity_sold
FROM gold.dim_product p
INNER JOIN gold.fact_sales s
    ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, p.category, p.subcategory, p.product_line
ORDER BY total_revenue DESC;

SELECT TOP 10
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    COUNT(s.order_number) AS order_count
FROM gold.dim_product p
INNER JOIN gold.fact_sales s
    ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, p.category, p.subcategory
ORDER BY order_count ASC;

SELECT 
    YEAR(order_date) AS sales_year,
    MONTH(order_date) AS sales_month,
    SUM(sales_amount) AS total_sales,
    COUNT(order_number) AS order_count,
    AVG(sales_amount) AS average_sale
FROM gold.fact_sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY sales_year, sales_month;

SELECT 
    YEAR(order_date) AS sales_year,
    DATEPART(QUARTER, order_date) AS sales_quarter,
    SUM(sales_amount) AS total_sales,
    COUNT(order_number) AS order_count,
    AVG(sales_amount) AS average_sale
FROM gold.fact_sales
GROUP BY YEAR(order_date), DATEPART(QUARTER, order_date)
ORDER BY sales_year, sales_quarter;

SELECT 
    YEAR(order_date) AS sales_year,
    SUM(sales_amount) AS total_sales,
    COUNT(order_number) AS order_count,
    AVG(sales_amount) AS average_sale,
    SUM(quantity) AS total_units_sold
FROM gold.fact_sales
GROUP BY YEAR(order_date)
ORDER BY sales_year;

SELECT 
    AVG(sales_amount) AS average_sale_amount,
    MIN(sales_amount) AS minimum_sale,
    MAX(sales_amount) AS maximum_sale,
    STDEV(sales_amount) AS std_deviation
FROM gold.fact_sales;

SELECT 
    c.country,
    SUM(s.price) AS total_revenue,
    COUNT(s.order_number) AS order_count,
    COUNT(DISTINCT s.customer_id) AS unique_customers,
    AVG(s.price) AS average_order_value
FROM gold.fact_sales s
INNER JOIN gold.dim_customers c 
    ON s.customer_id = c.customer_id
WHERE c.country IS NOT NULL
GROUP BY c.country
ORDER BY total_revenue DESC;