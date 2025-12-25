USE MASTER;
USE COLLAGE_PROJECT;
GO

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_key,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    ci.cst_marital_status AS marital_status,
    ci.cst_gender AS gender,
    ci.cst_create_date AS create_date,
    ec.bdate AS birth_date,
    el.country AS country
FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust ec 
        ON ci.cst_id = ec.cid
    LEFT JOIN silver.erp_loc el 
        ON ci.cst_id = el.cid;
GO

IF OBJECT_ID('gold.dim_product', 'V') IS NOT NULL
    DROP VIEW gold.dim_product;
GO

CREATE VIEW gold.dim_product AS
SELECT
    prd.prd_id AS product_id,
    prd.prd_key AS product_key,
    prd.prd_nm AS product_name,
    prd.prd_cost AS cost,
    prd.prd_line AS product_line,
    prd.prd_start_dt AS start_date,
    cat.cat AS category,
    cat.subcat AS subcategory,
    cat.maintenance AS maintenance_flag
FROM silver.crm_prd_info prd
    LEFT JOIN silver.erp_cat cat 
        ON prd.prd_id = cat.id;
GO

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
    s.sls_ord_num AS order_number,
    s.sls_prd_id AS product_id,
    s.sls_cust_id AS customer_id,
    s.sls_order_dt AS order_date,
    s.sls_ship_dt AS ship_date,
    s.sls_due_dt AS due_date,
    s.sls_sales AS sales_amount,
    s.sls_quantity AS quantity,
    s.sls_price AS price
FROM silver.crm_sales_info s;
GO