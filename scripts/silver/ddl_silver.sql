-- ===========================================================
-- Script: Create Silver Layer Tables for Data Warehouse
-- Author: Mayuresh Chourikar
-- Description: Defines cleaned and transformed tables in the Silver layer.
-- Last Modified: 2025-06-16
-- ===========================================================

-- Use the DataWarehouse database
USE DataWarehouse;
GO

-- ===========================================================
-- Table: silver.crm_cust_info
-- Description: Cleaned CRM customer information
-- ===========================================================
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE
);
GO

-- ===========================================================
-- Table: silver.crm_prd_info
-- Description: Cleaned CRM product information with derived fields
-- ===========================================================
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(20),
    prd_start_dt DATE,
    prd_end_dt DATE
);
GO

-- ===========================================================
-- Table: silver.crm_sales_details
-- Description: Cleaned CRM sales transaction details
-- ===========================================================
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);
GO

-- ===========================================================
-- Table: silver.erp_cust_az12
-- Description: Transformed ERP customer demographic data
-- ===========================================================
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
    CID NVARCHAR(50),
    BDATE DATE,
    GEN NVARCHAR(50)
);
GO

-- ===========================================================
-- Table: silver.erp_loc_a101
-- Description: Cleaned ERP customer location data
-- ===========================================================
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
    cid NVARCHAR(50),
    cntry NVARCHAR(50)
);
GO

-- ===========================================================
-- Table: silver.erp_px_cat_g1v2
-- Description: Transformed ERP product category mapping
-- ===========================================================
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50)
);
GO
