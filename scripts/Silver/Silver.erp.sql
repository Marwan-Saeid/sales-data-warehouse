USE MASTER;
USE COLLAGE_PROJECT;
GO

IF OBJECT_ID('silver.erp_cust', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust;
GO

CREATE TABLE silver.erp_cust (
    cid    INT,
    bdate  DATE,
    gender NVARCHAR(30),
    CONSTRAINT fk_erp_crm_cust FOREIGN KEY (cid)
        REFERENCES silver.crm_cust_info(cst_id)
);
GO

INSERT INTO silver.erp_cust (
    cid,
    bdate,
    gender
)
SELECT 
    RIGHT(cid, 5) AS cid,
    bdate,
    CASE UPPER(TRIM(gender))
        WHEN 'F'      THEN 'Female'
        WHEN 'FEMALE' THEN 'Female'
        WHEN 'M'      THEN 'Male'
        WHEN 'MALE'   THEN 'Male'
        ELSE 'N/A'
    END AS gender
FROM bronze.erp_cust
WHERE bdate <= GETDATE();
GO

IF OBJECT_ID('silver.erp_cat', 'U') IS NOT NULL
    DROP TABLE silver.erp_cat;
GO

CREATE TABLE silver.erp_cat (
    id          INT,
    cat         NVARCHAR(20),
    subcat      NVARCHAR(20),
    maintenance NVARCHAR(20),
    CONSTRAINT fk_cat_prd FOREIGN KEY (id)
        REFERENCES silver.crm_prd_info(prd_id)
);
GO

INSERT INTO silver.erp_cat (
    id,
    cat,
    subcat,
    maintenance
)
SELECT 
    p.prd_id AS id,
    UPPER(TRIM(c.cat)) AS cat,
    UPPER(TRIM(c.subcat)) AS subcat,
    UPPER(TRIM(c.maintenance)) AS maintenance
FROM bronze.erp_cat c
INNER JOIN silver.crm_prd_info p
    ON REPLACE(UPPER(TRIM(c.id)), '_', '-') = SUBSTRING(p.prd_key, 1, 5);
GO

IF OBJECT_ID('silver.erp_loc', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc;
GO

CREATE TABLE silver.erp_loc (
    cid     INT,
    country NVARCHAR(30),
    CONSTRAINT fk_loc_crm_cust FOREIGN KEY (cid)
        REFERENCES silver.crm_cust_info(cst_id)
);
GO

INSERT INTO silver.erp_loc (
    cid,
    country
)
SELECT 
    c.cst_id AS cid,
    ISNULL(l.cntry, 'N/A') AS country
FROM bronze.erp_loc l
INNER JOIN bronze.crm_cust_info c
    ON REPLACE(l.cid, '-', '') = c.cst_key;
GO