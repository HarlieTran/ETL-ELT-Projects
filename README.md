# ETL & ELT Projects (Oracle)

This repository contains two Oracle-focused ETL/ELT sample projects: a Sales data warehouse project (with sample CSV data) and a Human Resources data mart project (with SQL scripts and sample ETL artifacts). The assets are intended for learning and demo use — to run them you'll need an Oracle database and appropriate tools to load CSVs and execute the provided SQL scripts.

## Stack
- Language(s): PLSQL (SQL, PL/SQL scripts)
- Runtime / Platform: Oracle Database (12c/18c/19c/21c or Oracle XE)
- Notable tools / approaches: SQL*Plus / SQLcl, SQL Developer, SQL*Loader or External Tables for CSV loading

## How it's organized
```
oracle-etl-sales-project/      -- Sales data warehouse project
  WWI DB Create ALL Tables.sql -- DDL for sample WWI database
  data-warehouse-create.sql    -- DDL for DW (staging/dim/fact)
  data-warehouse-etl.sql       -- ETL / ELT scripts for transforming/loading DW
  WWI_DB_Data/                 -- CSV sample data used by the sales ETL
    Cities.csv
    Colors.csv
    Countries.csv
    Customers.csv
    OrderLines.csv
    Orders.csv
    People.csv
    StockItems.csv
    ... (other CSV files)

oracle-human-resources-project/ -- Human resources ETL / Data Mart
  HR_STG_Create.sql            -- staging table creation scripts
  HR_STG_Extract.sql           -- extract scripts (source->staging)
  HR_DB_Create.sql             -- data warehouse / DB create scripts
  HR_DB_Populate.sql           -- population scripts to load data
  HR_DIM_Transform_Load.sql    -- dimension transform & load
  HR_DM_Create.sql             -- data mart (facts/dim) create scripts
  HR_FINAL.xml, PROJ_ODI_*.xml -- ETL tool project exports and metadata
  HR_ETL.png, HR_DataMart.png  -- architecture / data flow diagrams
  GRP8_HR_Workforce_Insights_Dashboard.pbix -- Power BI sample report
```

How it fits together:
- The sales project contains a small OLTP-style WWI dataset (CSV) and a set of DDL/ETL scripts to build a dimensional data warehouse and to load it from the CSVs.
- The HR project contains scripts to create staging, dimension, and data mart objects; ETL extract/transform scripts; project export XMLs (likely from ODI/ODI-like tool), and visual artifacts (diagrams and a Power BI file).

## How to run it (short path)
1. Prepare an Oracle database (local or cloud). Create a user/schema for the project and grant required privileges.
2. Choose a CSV loading method:
   - SQL*Loader: create control files to load the CSVs into the staging tables defined in HR_STG_Create.sql or your staging schema.
   - External Tables: define external table definitions pointing at the CSV files and use INSERT ... SELECT to populate staging.
   - SQL Developer / SQLcl: open the CSV in the tool and use the import wizards.

Example using SQL*Plus / SQLcl (adjust connection details):

```sh
# connect to the DB
sqlplus username/password@//HOST:PORT/SERVICE

# run staging create
@oracle-human-resources-project/HR_STG_Create.sql

# load CSVs (using SQL*Loader or external tables) into staging
# (SQL*Loader example - create control file first)
sqlldr username/password@//HOST:PORT/SERVICE control=load_customers.ctl

# create DB objects
@oracle-human-resources-project/HR_DB_Create.sql

# populate and transform
@oracle-human-resources-project/HR_DB_Populate.sql
@oracle-human-resources-project/HR_DIM_Transform_Load.sql
@oracle-human-resources-project/HR_DM_Create.sql
```

Example using External Tables (conceptual):
- Copy CSVs to a directory accessible by the Oracle server.
- Create a DIRECTORY object and grant read on it.
- Create external table definitions and run INSERT INTO staging_table SELECT * FROM external_table;

Notes and prerequisites:
- You need an Oracle DB installation (or cloud DB as a service) and privileges to create tables, directories, and load data.
- Large CSVs (OrderLines.csv, Orders.csv) are included; don't open them in the browser if your environment struggles with large files.
- The SQL scripts assume typical schema names — review scripts and update schema/user names before running.

## Files of interest (quick pointers)
- Sales: oracle-etl-sales-project/data-warehouse-etl.sql and data-warehouse-create.sql
- Sales sample data: oracle-etl-sales-project/WWI_DB_Data/ (CSV files)
- HR ETL flow: oracle-human-resources-project/HR_STG_Create.sql, HR_STG_Extract.sql, HR_DB_Create.sql, HR_DB_Populate.sql, HR_DIM_Transform_Load.sql
- Diagrams: oracle-human-resources-project/HR_ETL.png, HR_DataMart.png

## Contributing
This is a personal/demo repository. If you'd like to contribute:
- Open an issue describing suggested changes or improvements.
- For SQL or ETL improvements, include before/after scripts and a short test plan.

## License
No license file is included. Treat contents as demonstration materials — check with the repository owner before using in production.

---

If you'd like, I can:
- Add usage examples (SQL*Loader control files or external table definitions) tailored to these CSV files.
- Add a CONTRIBUTING.md and LICENSE file.
- Break the README into separate READMEs inside each project directory (sales/ and hr/).
