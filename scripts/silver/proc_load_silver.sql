/* =============================================
Procedure : silver.load_silver
   Author    : Mayuresh Chourikar
   Created   : 2025-06-16
   Purpose   : Cleans and transforms data from Bronze to Silver layer
   Description:
     - Standardizes and deduplicates CRM data
     - Formats dates and fixes invalid values in sales details
     - Maps ERP codes to readable forms
     - Ensures clean, analytics-ready data

   Parameters: None

   Steps Performed:
     1. silver.crm_cust_info      → deduplication + formatting
     2. silver.crm_prd_info       → key parsing + date adjustment
     3. silver.crm_sales_details  → date conversion + sales validation
     4. silver.erp_cust_az12      → ID & gender normalization
     5. silver.erp_loc_a101       → country mapping
     6. silver.erp_px_cat_g1v2    → direct copy

   Error Handling:
     - TRY...CATCH block logs full error message, number, and state

   Execution:
     EXEC silver.load_silver;
============================================= */
CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    BEGIN TRY
        DECLARE 
            @batch_start_time DATETIME, 
            @batch_end_time DATETIME, 
            @start_time DATETIME, 
            @end_time DATETIME;

        PRINT '======================================';
        PRINT 'Starting Silver Layer Data Load';
        PRINT '======================================';

        SET @batch_start_time = GETDATE();

        -- ==================================================
        -- Load: silver.crm_cust_info
        -- ==================================================
        PRINT '>> Truncating table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Inserting cleaned data into silver.crm_cust_info';
        SET @start_time = GETDATE();

        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE 
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END,
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END,
            cst_create_date
        FROM (
            SELECT *, 
                   ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flaglast
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flaglast = 1;

        SET @end_time = GETDATE();

        -- ==================================================
        -- Load: silver.crm_prd_info
        -- ==================================================
        PRINT '>> Truncating table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT '>> Inserting cleaned data into silver.crm_prd_info';
        SET @start_time = GETDATE();

        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
            prd_nm,
            ISNULL(prd_cost, 0),
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END,
            CAST(prd_start_dt AS DATE),
            CAST(DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS DATE)
        FROM bronze.crm_prd_info;

        SET @end_time = GETDATE();

        -- ==================================================
        -- Load: silver.crm_sales_details
        -- ==================================================
        PRINT '>> Truncating table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT '>> Inserting cleaned data into silver.crm_sales_details';
        SET @start_time = GETDATE();

        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE 
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END,
            CASE 
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END,
            CASE 
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END,
            CASE 
                WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END,
            sls_quantity,
            CASE 
                WHEN sls_price IS NULL OR sls_price <= 0
                THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END
        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();

        -- ==================================================
        -- Load: silver.erp_cust_az12
        -- ==================================================
        PRINT '>> Truncating table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT '>> Inserting cleaned data into silver.erp_cust_az12';
        SET @start_time = GETDATE();

        INSERT INTO silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        SELECT
            CASE 
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END,
            CASE 
                WHEN bdate > GETDATE() THEN NULL
                ELSE bdate
            END,
            CASE 
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'n/a'
            END
        FROM bronze.erp_cust_az12;

        SET @end_time = GETDATE();

        -- ==================================================
        -- Load: silver.erp_loc_a101
        -- ==================================================
        PRINT '>> Truncating table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT '>> Inserting cleaned data into silver.erp_loc_a101';
        SET @start_time = GETDATE();

        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT
            REPLACE(cid, '-', ''),
            CASE 
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
                WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
                ELSE TRIM(cntry)
            END
        FROM bronze.erp_loc_a101;

        SET @end_time = GETDATE();

        -- ==================================================
        -- Load: silver.erp_px_cat_g1v2
        -- ==================================================
        PRINT '>> Truncating table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT '>> Inserting cleaned data into silver.erp_px_cat_g1v2';
        SET @start_time = GETDATE();

        INSERT INTO silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            id,
            cat,
            subcat,
            maintenance
        FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();

        -- ==================================================
        -- Final Log
        -- ==================================================
        SET @batch_end_time = GETDATE();
        PRINT '======================================';
        PRINT 'Silver Layer Data Load Complete';
        PRINT '>> Total Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '======================================';

    END TRY
    BEGIN CATCH
        PRINT '======================================';
        PRINT 'Error Occurred During Silver Layer Load';
        PRINT 'Message     : ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'State       : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '======================================';
    END CATCH
END;
GO

-- Execute the procedure
EXEC silver.load_silver;
