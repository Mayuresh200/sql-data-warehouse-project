
# SQL Data Warehouse Project

This project is a complete end-to-end implementation of a SQL-based Data Warehouse using the Bronze-Silver-Gold architecture pattern. It includes raw data ingestion, transformation logic, data quality validation, and semantic modeling for business intelligence and reporting.

## Project Structure

```
.
├── datasets/
│   ├── source_crm/            # Raw CRM source data (cust, product, sales)
│   └── source_erp/            # Raw ERP source data (customer info, categories, location)
├── diagrams/                  # Data architecture and flow diagrams (Draw.io SVGs)
├── docs/                      # Metadata documentation and data catalog
├── scripts/
│   ├── bronze/                # DDL and load scripts for Bronze layer
│   ├── silver/                # DDL and load scripts for Silver layer
│   └── gold layer/            # DDL scripts for Gold layer views
├── tests/                     # Data quality validation scripts
└── README.md                  # Project overview and documentation
```

## Objective

To design and implement a scalable and maintainable data warehouse architecture using Microsoft SQL Server. The project follows the medallion architecture approach to separate raw data, cleansed data, and analytics-ready data.

## Architecture

- Bronze Layer: Raw data ingestion from CSV files using BULK INSERT
- Silver Layer: Data cleaning, validation, standardization
- Gold Layer: Dimensional modeling (Fact & Dimension views) for reporting

Refer to the diagrams in the `/diagrams` folder for full architecture, data flow, and integration model.

## Key Components

### Datasets
Stored in `datasets/source_crm` and `datasets/source_erp`. These are used to simulate real-world CRM and ERP data.

### ETL Scripts
Located in the `scripts/` directory, broken down by layers:
- Bronze: Raw table DDL and ingestion logic (`proc_load_bronze.sql`)
- Silver: Transformation, cleaning, and load logic (`proc_load_silver.sql`)
- Gold: Final dimensional views for reporting (`ddl_gold.sql`)

### Validation Scripts
In `tests/`, used to validate:
- Surrogate key uniqueness
- Referential integrity across layers
- Standardized formats and derived fields

## Documentation

- Data Catalog: Located in `docs/GOLD_LAYER_DATA_CATALOG.md`, describing each table and column in the Gold layer.
- Draw.io Diagrams: Visuals in `/diagrams` for architecture, flow, and schema design.

## Technologies Used

- SQL Server / SSMS
- Draw.io (for diagrams)
- GitHub (for version control and documentation)

## How to Use

1. Clone the repo and set up SQL Server locally.
2. Run scripts in order:
   - `scripts/init_database.sql`
   - `scripts/bronze/proc_load_bronze.sql`
   - `scripts/silver/proc_load_silver.sql`
   - `scripts/gold layer/ddl_gold.sql`
3. Use validation scripts in `/tests/` to verify data integrity.
4. Refer to diagrams for architecture understanding and data flow tracing.

## Author

**Mayuresh Chourikar**

- Data Analyst passionate about building end-to-end data pipelines and analytical solutions.
- Proficient in SQL, Power BI, Python (Pandas), Tableau, and data modeling.
- Experienced in creating dashboards, writing ETL pipelines, and validating data quality.
- Connect with me on [LinkedIn](https://www.linkedin.com/in/mayureshchourikar)

## License

This project is licensed under the MIT License.
