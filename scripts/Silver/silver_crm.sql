USE MASTER;
USE COLLAGE_PROJECT;


IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;

CREATE TABLE silver.crm_cust_info (
    cst_id             INT PRIMARY KEY,        
    cst_key            NVARCHAR(20),         
    cst_firstname      NVARCHAR(20),           
    cst_lastname       NVARCHAR(20),          
    cst_marital_status NVARCHAR(20),         
    cst_gender         NVARCHAR(20),         
    cst_create_date    DATE                  
);

INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gender,
    cst_create_date
)
SELECT
    cst_id,
    cst_key,
    UPPER(TRIM(cst_firstname)) AS cst_firstname,
    UPPER(TRIM(cst_lastname)) AS cst_lastname,
    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'N/A'
    END AS cst_marital_status,
    CASE
        WHEN UPPER(TRIM(cst_gender)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gender)) = 'M' THEN 'Male'
        ELSE 'N/A'
    END AS cst_gender,
    CASE
        WHEN cst_create_date > GETDATE() THEN DATEADD(YEAR, -1, cst_create_date)
        ELSE cst_create_date
    END AS cst_create_date
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY cst_id
               ORDER BY cst_create_date DESC
           ) AS rn
    FROM bronze.crm_cust_info
    WHERE cst_firstname IS NOT NULL
      AND cst_lastname IS NOT NULL
      AND cst_create_date IS NOT NULL
) t
WHERE rn = 1;

IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info (
    prd_id       INT PRIMARY KEY,
    prd_key      NVARCHAR(20),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(20),
    prd_start_dt DATE
);

WITH cte AS (
    SELECT
        ROW_NUMBER() OVER (PARTITION BY prd_key ORDER BY prd_id) AS rn,
        ROW_NUMBER() OVER (ORDER BY prd_id) AS new_prd_id,
        prd_key,
        UPPER(TRIM(prd_nm)) AS prd_nm,
        ISNULL(prd_cost, AVG(prd_cost) OVER ()) AS prd_cost,
        CASE
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Standard'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'N/A'
        END AS prd_line,
        prd_start_dt
    FROM bronze.crm_prd_info
)
INSERT INTO silver.crm_prd_info (
    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt
)
SELECT
    new_prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt
FROM cte
WHERE rn = 1;

IF OBJECT_ID('silver.crm_sales_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_info;

CREATE TABLE silver.crm_sales_info (
    sls_ord_num  NVARCHAR(20),
    sls_prd_id   INT,
    sls_cust_id  INT,
    sls_order_dt DATE,
    sls_ship_dt  DATE,
    sls_due_dt   DATE,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT,
    CONSTRAINT fk_sales_cust FOREIGN KEY (sls_cust_id) 
        REFERENCES silver.crm_cust_info(cst_id),
    CONSTRAINT fk_sales_prd FOREIGN KEY (sls_prd_id)
        REFERENCES silver.crm_prd_info(prd_id)
);

INSERT INTO silver.crm_sales_info (
    sls_ord_num,
    sls_prd_id,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT 
    UPPER(TRIM(s.sls_ord_num)) AS sls_ord_num,
    p.prd_id AS sls_prd_id,
    s.sls_cust_id,
    CASE
        WHEN LEN(s.sls_order_dt) = 8 THEN CAST(s.sls_order_dt AS DATE)
        ELSE NULL
    END AS sls_order_dt,
    CAST(s.sls_ship_dt AS DATE) AS sls_ship_dt,
    CAST(s.sls_due_dt AS DATE) AS sls_due_dt,
    CASE 
        WHEN s.sls_sales < 0 THEN ABS(s.sls_sales)
        WHEN s.sls_sales = 0 THEN 
            CASE 
                WHEN s.sls_quantity > 0 THEN s.sls_price / s.sls_quantity
                ELSE NULL
            END
        ELSE s.sls_sales
    END AS sls_sales,
    s.sls_quantity,
    CASE
        WHEN s.sls_sales IS NOT NULL AND s.sls_quantity IS NOT NULL 
            THEN ABS(s.sls_sales * s.sls_quantity)
        ELSE ABS(s.sls_price)
    END AS sls_price
FROM bronze.crm_sales_info s
INNER JOIN silver.crm_prd_info p
    ON s.sls_prd_key = SUBSTRING(p.prd_key, 7, LEN(p.prd_key))
WHERE s.sls_sales IS NOT NULL;