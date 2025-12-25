USE MASTER;
IF EXISTS (
    SELECT NAME 
    FROM SYS.DATABASES 
    WHERE NAME = 'COLLAGE_PROJECT'
)
BEGIN
    DROP DATABASE COLLAGE_PROJECT;
END
CREATE DATABASE COLLAGE_PROJECT;
USE COLLAGE_PROJECT;
IF EXISTS (SELECT 1 FROM SYS.SCHEMAS WHERE NAME = 'bronze')
BEGIN
    DROP SCHEMA bronze;
END
CREATE SCHEMA bronze;
IF EXISTS (SELECT 1 FROM SYS.SCHEMAS WHERE NAME = 'silver')
BEGIN
    DROP SCHEMA silver;
END
CREATE SCHEMA silver;
IF EXISTS (SELECT 1 FROM SYS.SCHEMAS WHERE NAME = 'gold')
BEGIN
    DROP SCHEMA gold;
END
CREATE SCHEMA gold;
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.crm_cust_info;
END
CREATE TABLE bronze.crm_cust_info (
    CST_ID              INT,                
    CST_KEY             NVARCHAR(20),       
    CST_FIRSTNAME       NVARCHAR(20),       
    CST_LASTNAME        NVARCHAR(20),       
    CST_MARITAL_STATUS  NVARCHAR(20),       
    CST_GENDER          NVARCHAR(20),       
    CST_CREATE_DATE     DATE                
);
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.crm_prd_info;
END
CREATE TABLE bronze.crm_prd_info (
    PRD_ID          INT,                    
    PRD_KEY         NVARCHAR(20),           
    PRD_NM          NVARCHAR(50),           
    PRD_COST        BIGINT,                 
    PRD_LINE        NVARCHAR(20),           
    PRD_START_DT    DATE,                   
    PRD_END_DT      DATE                    
);
IF OBJECT_ID('bronze.crm_sales_info', 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.crm_sales_info;
END
CREATE TABLE bronze.crm_sales_info (
    SLS_ORD_NUM     NVARCHAR(20),          
    SLS_PRD_KEY     NVARCHAR(20),          
    SLS_CUST_ID     INT,                   
    SLS_ORDER_DT    NVARCHAR(20),          
    SLS_SHIP_DT     NVARCHAR(20),          
    SLS_DUE_DT      NVARCHAR(20),          
    SLS_SALES       INT,                   
    SLS_QUANTITY    INT,                   
    SLS_PRICE       INT                    
);
TRUNCATE TABLE bronze.crm_cust_info;
BULK INSERT bronze.crm_cust_info
FROM 'F:\marwan\Collage\datasets\source_crm/cust_info.csv'
WITH (
    FIRSTROW = 2,                         
    FIELDTERMINATOR = ',',                
    TABLOCK                               
);
TRUNCATE TABLE bronze.crm_prd_info;
BULK INSERT bronze.crm_prd_info
FROM 'F:\marwan\Collage\datasets\source_crm/prd_info.csv'
WITH (
    FIRSTROW = 2,                           
    FIELDTERMINATOR = ',',                  
    TABLOCK                                 
);
TRUNCATE TABLE bronze.crm_sales_info;
BULK INSERT bronze.crm_sales_info
FROM 'F:\marwan\Collage\datasets\source_crm/sales_details.csv'
WITH (
    FIRSTROW = 2,                           
    FIELDTERMINATOR = ',',                  
    TABLOCK                                 
);