/* ================================================================
   Script: Silver Layer Data Cleaning & Validation
   Author: Mayuresh Chourikar
   Purpose: Validate and audit data quality in Silver Layer tables
   Usage: Run after Bronze-to-Silver transformations, before Gold load
================================================================== */

USE DataWarehouse;
GO

-- =============================================================
-- SECTION 1: Validate silver.crm_cust_info
-- =============================================================

-- Check for duplicates or nulls in primary key (cst_id)
SELECT 
    cst_id,
    COUNT(*) AS duplicate_count
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted spaces in cst_firstname
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Check distinct values for marital status
SELECT DISTINCT cst_marital_status 
FROM bronze.crm_cust_info;

-- Validate deduplication logic using row_number()
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flaglast
    FROM bronze.crm_cust_info
) t
WHERE flaglast = 1 AND cst_id = 29466;

-- =============================================================
-- SECTION 2: Validate silver.crm_prd_info
-- =============================================================

-- Check for duplicates or nulls in prd_id
SELECT 
    prd_id,
    COUNT(*) AS duplicate_count
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted spaces in prd_nm
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for null or negative prd_cost
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Review product line codes for standardization
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;

-- Validate logic to derive prd_end_dt using LEAD()
SELECT
    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt,
    CAST(DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS DATE) AS expected_end_dt
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');

-- Check Silver table for invalid values
SELECT prd_id, COUNT(*) AS duplicate_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Validate final values in product line
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Check for inconsistent date ordering
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- =============================================================
-- SECTION 3: Validate silver.crm_sales_details
-- =============================================================

-- Validate order date: range, length, and value
SELECT sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
   OR LEN(sls_order_dt) != 8
   OR sls_order_dt > 20500101
   OR sls_order_dt < 19000101;

-- Validate ship date
SELECT sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 
   OR LEN(sls_ship_dt) != 8
   OR sls_ship_dt > 20500101
   OR sls_ship_dt < 19000101;

-- Validate due date
SELECT sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
   OR LEN(sls_due_dt) != 8
   OR sls_due_dt > 20500101
   OR sls_due_dt < 19000101;

-- Check date logic: order_date should be before ship/due
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Validate consistency of sales, quantity, and price
SELECT DISTINCT
    sls_sales AS old_sales,
    sls_quantity AS old_qty,
    sls_price AS old_price,
    CASE 
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS calculated_sales,
    CASE 
        WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS adjusted_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- =============================================================
-- SECTION 4: Validate silver.erp_cust_az12
-- =============================================================

-- Validate CID lengths
SELECT DISTINCT LEN(cid) AS cid_length
FROM silver.erp_cust_az12;

-- Check unmatched ERP customer IDs against CRM
SELECT cid, bdate, gen
FROM bronze.erp_cust_az12
WHERE CASE 
          WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
          ELSE cid
      END NOT IN (
          SELECT DISTINCT cst_key FROM silver.crm_cust_info
      );

-- Filter future birthdates
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();

-- Validate gender values
SELECT DISTINCT gen
FROM silver.erp_cust_az12;

-- =============================================================
-- SECTION 5: Validate silver.erp_px_cat_g1v2
-- =============================================================

-- Check join possibility between prd_key and category ID
SELECT DISTINCT prd_key
FROM silver.crm_prd_info;

-- Trim whitespace in category values
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);

-- Review unique values in category fields
SELECT DISTINCT cat FROM bronze.erp_px_cat_g1v2;
SELECT DISTINCT subcat FROM bronze.erp_px_cat_g1v2;
SELECT DISTINCT maintenance FROM bronze.erp_px_cat_g1v2;

-- Final table inspection
SELECT *
FROM silver.erp_px_cat_g1v2;

-- =============================================================
-- SECTION 6: Validate silver.erp_loc_a101
-- =============================================================

-- Validate that customer IDs match CRM data
SELECT cid
FROM silver.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (
    SELECT cst_key FROM silver.crm_cust_info
);

-- Check all customer keys
SELECT DISTINCT cst_key
FROM silver.crm_cust_info;

-- Analyze country code cardinality
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101
ORDER BY cntry;
