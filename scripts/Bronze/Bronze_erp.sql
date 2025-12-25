USE MASTER;
USE COLLAGE_PROJECT;
IF OBJECT_ID('bronze.erp_cust', 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.erp_cust;
END
CREATE TABLE bronze.erp_cust (
    CID         NVARCHAR(20),               
    BDATE       DATE,                       
    GENDER      VARCHAR(20)                 
);
IF OBJECT_ID('bronze.erp_loc', 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.erp_loc;
END
CREATE TABLE bronze.erp_loc (
    CID         NVARCHAR(20),               
    CNTRY       NVARCHAR(20)                
);
IF OBJECT_ID('bronze.erp_cat', 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.erp_cat;
END
CREATE TABLE bronze.erp_cat (
    ID              NVARCHAR(20),           
    CAT             NVARCHAR(20),           
    SUBCAT          NVARCHAR(20),           
    MAINTENANCE     NVARCHAR(20)            
);
TRUNCATE TABLE bronze.erp_cust;
BULK INSERT bronze.erp_cust
FROM 'F:\marwan\Collage\datasets\source_erp/CUST_AZ12.csv'
WITH (
    FIRSTROW = 2,                           
    FIELDTERMINATOR = ',',                  
    TABLOCK                                 
);
TRUNCATE TABLE bronze.erp_loc;
BULK INSERT bronze.erp_loc
FROM 'F:\marwan\Collage\datasets\source_erp/LOC_A101.csv'
WITH (
    FIRSTROW = 2,                
    FIELDTERMINATOR = ',',                  
    TABLOCK                                 
);
TRUNCATE TABLE bronze.erp_cat;
BULK INSERT bronze.erp_cat
FROM 'F:\marwan\Collage\datasets\source_erp/PX_CAT_G1V2.csv'
WITH (
    FIRSTROW = 2,                           
    FIELDTERMINATOR = ',',                  
    TABLOCK                                 
);