/* ================================================================
   Script: Create Gold Layer Views (Fact and Dimension Tables)
   Layer: Gold (Reporting Layer)
   Purpose: 
     - Defines analytical views for reporting and dashboards
     - Combines cleaned data from Silver layer into dimensional model
     - Follows star schema design: fact_sales with dim_customers & dim_products

   Usage:
     - Used as the final layer for BI tools (Power BI, Tableau, etc.)
     - Supports queries on sales, customer demographics, and product performance
================================================================== */

USE DataWarehouse;
GO

-- =============================================================
-- View: gold.fact_sales
-- Description: Central fact table combining customer, product, and sales metrics
-- =============================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
    sd.sls_ord_num      AS order_number,
    pr.product_key      AS product_key,
    cu.customer_key     AS customer_key,
    sd.sls_order_dt     AS order_date,
    sd.sls_ship_dt      AS ship_date,
    sd.sls_due_dt       AS due_date,
    sd.sls_sales        AS sales,
    sd.sls_quantity     AS sales_quantity,
    sd.sls_price        AS sales_price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;
GO

-- =============================================================
-- View: gold.dim_customers
-- Description: Customer dimension combining CRM and ERP data
-- =============================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id)      AS customer_key,
    ci.cst_id                                   AS customer_id,
    ci.cst_key                                  AS customer_number,
    ci.cst_firstname                            AS first_name,
    ci.cst_lastname                             AS last_name,
    la.cntry                                    AS country,
    ci.cst_marital_status                       AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END                                         AS gender,
    ca.BDATE                                     AS birthdate,
    ci.cst_create_date                          AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.CID
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;
GO

-- =============================================================
-- View: gold.dim_products
-- Description: Product dimension with category details and active products only
-- =============================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT  
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
    pn.prd_id                                                 AS product_id,
    pn.prd_key                                                AS product_number,
    pn.prd_nm                                                 AS product_name,
    pn.cat_id                                                 AS category_id,
    pc.cat                                                    AS category,
    pc.subcat                                                 AS subcategory,
    pc.maintenance                                            AS maintenance,
    pn.prd_cost                                               AS cost,
    pn.prd_line                                               AS product_line,
    pn.prd_start_dt                                           AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL;  -- Exclude historical products
GO
