-- =============================================
-- Script: Data Warehouse Initialization
-- Author: Mayuresh Chourikar
-- Purpose: Create a Data Warehouse structure with Bronze, Silver, and Gold schemas
-- Last Modified: 2025-06-10
-- =============================================

-- Step 1: Create the Data Warehouse Database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    CREATE DATABASE DataWarehouse;
    PRINT 'Database [DataWarehouse] created successfully.';
END
ELSE
BEGIN
    PRINT 'Database [DataWarehouse] already exists.';
END
GO

-- Step 2: Switch context to the new database
USE DataWarehouse;
GO

-- Step 3: Create Schemas for Layered Architecture
-- Bronze Layer: Raw data ingestion layer
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
BEGIN
    EXEC('CREATE SCHEMA bronze');
    PRINT 'Schema [bronze] created.';
END
ELSE
BEGIN
    PRINT 'Schema [bronze] already exists.';
END
GO

-- Silver Layer: Cleaned and transformed data
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
BEGIN
    EXEC('CREATE SCHEMA silver');
    PRINT 'Schema [silver] created.';
END
ELSE
BEGIN
    PRINT 'Schema [silver] already exists.';
END
GO

-- Gold Layer: Final curated data for analytics/reporting
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
BEGIN
    EXEC('CREATE SCHEMA gold');
    PRINT 'Schema [gold] created.';
END
ELSE
BEGIN
    PRINT 'Schema [gold] already exists.';
END
GO
