
# 📘 Gold Layer Data Catalog

This catalog documents the structure and purpose of each **view** in the Gold Layer of the data warehouse. The Gold Layer serves as the **final semantic layer** optimized for BI consumption and reporting.

---

## 🧾 Table of Contents
- [fact_sales](#fact_sales)
- [dim_customers](#dim_customers)
- [dim_products](#dim_products)

---

## 🔹 `gold.fact_sales`

**Type:** View  
**Grain:** One row per sales order line  
**Source Tables:**  
- `silver.crm_sales_details`  
- `gold.dim_customers`  
- `gold.dim_products`  

**Description:**  
Central fact view that links transactional sales data with customer and product dimensions for analytical reporting.

| Column Name      | Data Type | Description                          |
|------------------|-----------|--------------------------------------|
| order_number     | NVARCHAR  | Sales order identifier               |
| product_key      | INT       | Surrogate key from `dim_products`    |
| customer_key     | INT       | Surrogate key from `dim_customers`   |
| order_date       | DATE      | Date when the order was placed       |
| ship_date        | DATE      | Shipment date                        |
| due_date         | DATE      | Order due date                       |
| sales            | INT       | Total sales amount                   |
| sales_quantity   | INT       | Quantity sold                        |
| sales_price      | INT       | Unit price                           |

---

## 🔹 `gold.dim_customers`

**Type:** View  
**Grain:** One row per customer  
**Source Tables:**  
- `silver.crm_cust_info`  
- `silver.erp_cust_az12`  
- `silver.erp_loc_a101`  

**Description:**  
Customer dimension combining CRM and ERP details with standardized gender, country, and marital status values.

| Column Name      | Data Type | Description                          |
|------------------|-----------|--------------------------------------|
| customer_key     | INT       | Surrogate customer key (generated)   |
| customer_id      | INT       | Original CRM customer ID             |
| customer_number  | NVARCHAR  | Customer unique key from CRM         |
| first_name       | NVARCHAR  | First name of the customer           |
| last_name        | NVARCHAR  | Last name of the customer            |
| country          | NVARCHAR  | Country name (mapped from ERP)       |
| marital_status   | NVARCHAR  | Standardized marital status          |
| gender           | NVARCHAR  | Cleaned gender (CRM > ERP fallback)  |
| birthdate        | DATE      | Date of birth                        |
| create_date      | DATE      | Customer creation date               |

---

## 🔹 `gold.dim_products`

**Type:** View  
**Grain:** One row per active product  
**Source Tables:**  
- `silver.crm_prd_info`  
- `silver.erp_px_cat_g1v2`  

**Description:**  
Product dimension enriched with ERP category and subcategory data. Filters out inactive (historical) products.

| Column Name      | Data Type | Description                          |
|------------------|-----------|--------------------------------------|
| product_key      | INT       | Surrogate product key (generated)    |
| product_id       | INT       | Product ID from CRM                  |
| product_number   | NVARCHAR  | Full product key                     |
| product_name     | NVARCHAR  | Product name                         |
| category_id      | NVARCHAR  | ERP category ID                      |
| category         | NVARCHAR  | Category name (ERP)                  |
| subcategory      | NVARCHAR  | Subcategory (ERP)                    |
| maintenance      | NVARCHAR  | Maintenance tag/category             |
| cost             | INT       | Product cost                         |
| product_line     | NVARCHAR  | Standardized product line (e.g., Road, Mountain) |
| start_date       | DATE      | Product start/launch date            |

---

## 📌 Usage Notes

- Gold Layer views are **read-only** and designed for BI/reporting tools (Power BI, Tableau, etc.)
- These views **abstract away data transformations** performed in the Silver Layer.
- All surrogate keys (`product_key`, `customer_key`) are generated using `ROW_NUMBER()` logic.
