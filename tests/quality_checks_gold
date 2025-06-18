/* =============================================================
   Script: Quality Checks - Gold Layer Validation
   Author: Mayuresh Chourikar
   Purpose:
     - Verify data model consistency and integrity across fact and dimension views
     - Ensure uniqueness of surrogate keys
     - Detect mismatches between CRM and ERP values (e.g., gender)
   Usage:
     - Run this script after creating Gold views to validate the final layer
     - Helps catch anomalies before loading into reporting tools
   Last Modified: 2025-06-16
============================================================= */

USE DataWarehouse;
GO

-- =============================================================
-- 1. Referential Integrity Check: fact_sales → dim_customers & dim_products
-- Description: Ensures all keys in the fact table match a valid dimension record
-- Expectation: No nulls in product_key or customer_key
-- =============================================================
PRINT '>> Checking referential integrity in fact_sales';

SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL;

-- =============================================================
-- 2. Uniqueness Check: gold.dim_products.product_key
-- Description: Validates that each product has a unique surrogate key
-- Expectation: No duplicates
-- =============================================================
PRINT '>> Checking uniqueness of product_key in dim_products';

SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- =============================================================
-- 3. Uniqueness Check: gold.dim_customers.customer_key
-- Description: Validates that each customer has a unique surrogate key
-- Expectation: No duplicates
-- =============================================================
PRINT '>> Checking uniqueness of customer_key in dim_customers';

SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- =============================================================
-- 4. CRM vs ERP Gender Mismatch Check
-- Description: Identifies mismatched or conflicting gender values between CRM and ERP systems
-- Expectation: Cleaned field (new_gen) should resolve conflicts
-- =============================================================
PRINT '>> Checking mismatched gender values between CRM and ERP';

SELECT DISTINCT
    ci.cst_gndr         AS crm_gender,
    ca.GEN              AS erp_gender,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS resolved_gender
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.CID
LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid
ORDER BY 1, 2;
