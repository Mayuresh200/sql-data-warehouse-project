-- =============================================
-- Procedure: bronze.load_bronze
-- Author: Mayuresh Chourikar
-- Purpose: Load raw CSV data into Bronze layer tables
-- Last Modified: 2025-06-11
-- =============================================
CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    BEGIN TRY
        DECLARE 
            @start_time DATETIME, 
            @end_time DATETIME, 
            @batch_start_time DATETIME, 
            @batch_end_time DATETIME;

        PRINT '======================================';
        PRINT 'Starting Bronze Layer Data Load';
        PRINT '======================================';

        SET @batch_start_time = GETDATE();

        --------------------------------------------
        -- Load Table: bronze.crm_cust_info
        -- Description: CRM Customer Information
        --------------------------------------------
        PRINT 'Loading data into bronze.crm_cust_info...';
        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_cust_info;

        BULK INSERT bronze.crm_cust_info
        FROM 'D:\DATA Analysis\Projects\SQL PROJECTS\Data Warehousing\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT 'Load complete. Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        --------------------------------------------
        -- Load Table: bronze.crm_prd_info
        -- Description: CRM Product Information
        --------------------------------------------
        PRINT 'Loading data into bronze.crm_prd_info...';
        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_prd_info;

        BULK INSERT bronze.crm_prd_info
        FROM 'D:\DATA Analysis\Projects\SQL PROJECTS\Data Warehousing\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT 'Load complete. Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        --------------------------------------------
        -- Load Table: bronze.crm_sales_details
        -- Description: CRM Sales Transactions
        --------------------------------------------
        PRINT 'Loading data into bronze.crm_sales_details...';
        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_sales_details;

        BULK INSERT bronze.crm_sales_details
        FROM 'D:\DATA Analysis\Projects\SQL PROJECTS\Data Warehousing\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT 'Load complete. Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        --------------------------------------------
        -- Load Table: bronze.erp_cust_az12
        -- Description: ERP Customer Demographics
        --------------------------------------------
        PRINT 'Loading data into bronze.erp_cust_az12...';
        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_cust_az12;

        BULK INSERT bronze.erp_cust_az12
        FROM 'D:\DATA Analysis\Projects\SQL PROJECTS\Data Warehousing\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT 'Load complete. Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        --------------------------------------------
        -- Load Table: bronze.erp_loc_a101
        -- Description: ERP Customer Location
        --------------------------------------------
        PRINT 'Loading data into bronze.erp_loc_a101...';
        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_loc_a101;

        BULK INSERT bronze.erp_loc_a101
        FROM 'D:\DATA Analysis\Projects\SQL PROJECTS\Data Warehousing\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT 'Load complete. Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        --------------------------------------------
        -- Load Table: bronze.erp_px_cat_g1v2
        -- Description: ERP Product Category Mapping
        --------------------------------------------
        PRINT 'Loading data into bronze.erp_px_cat_g1v2...';
        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'D:\DATA Analysis\Projects\SQL PROJECTS\Data Warehousing\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT 'Load complete. Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Final summary
        SET @batch_end_time = GETDATE();
        PRINT '======================================';
        PRINT 'Bronze Layer Load Completed Successfully';
        PRINT 'Total Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '======================================';

    END TRY
    BEGIN CATCH
        PRINT '======================================';
        PRINT 'Error Occurred During Load';
        PRINT 'Message     : ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'State       : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT 'Severity    : ' + CAST(ERROR_SEVERITY() AS NVARCHAR);
        PRINT '======================================';
    END CATCH
END;
GO

-- Execute the procedure
EXEC bronze.load_bronze;
