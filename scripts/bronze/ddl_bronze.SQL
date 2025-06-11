-- =============================================
-- Script: Create Bronze Layer Tables for Data Warehouse
-- Author: Mayuresh Chourikar
-- Purpose: Create raw ingestion tables in the Bronze schema
-- Last Modified: 2025-06-11
-- =============================================

-- Switch to the DataWarehouse database
USE DataWarehouse;
GO

-- ===================================================
-- Table 1: bronze.crm_cust_info
-- Description: Customer master data from CRM system
-- ===================================================
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE
);
GO

-- ===================================================
-- Table 2: bronze.crm_prd_info
-- Description: Product master data from CRM system
-- ===================================================
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info (
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(20),
    prd_start_dt DATE,
    prd_end_dt DATE
);
GO

-- ===================================================
-- Table 3: bronze.crm_sales_details
-- Description: Sales transactions from CRM system
-- ===================================================
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
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

-- ===================================================
-- Table 4: bronze.erp_cust_az12
-- Description: Customer demographics from ERP (AZ12 module)
-- ===================================================
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12 (
    CID NVARCHAR(50),
    BDATE DATE,
    GEN NVARCHAR(50)
);
GO

-- ===================================================
-- Table 5: bronze.erp_loc_a101
-- Description: Customer location data from ERP (A101 module)
-- ===================================================
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101 (
    cid NVARCHAR(50),
    cntry NVARCHAR(50)
);
GO

-- ===================================================
-- Table 6: bronze.erp_px_cat_g1v2
-- Description: Product category mapping from ERP (G1V2 module)
-- ===================================================
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50)
);
GO
