# SQL Analysis – Hospital Analytics

This folder contains the SQL scripts used to create the hospital analytics database, define relational tables, load cleaned datasets, and perform data analysis using MySQL.

## Files Included

| File | Description |
|---|---|
| `01_Schema_creation_and_data_loading.sql` | Creates the `hospital_analytics` database. | Creates database tables with appropriate data types, primary keys, and foreign keys.
| `02_Analysis.sql` | Contains basic SQL queries for exploring hospital data. |
| `03_Advanced_Analysis.sql` | Contains advanced SQL analysis using joins, subqueries, CTEs, and window functions. |

## Tools Used

- MySQL
- SQL

## Key Activities

- Database creation and table design.
- Defining primary key and foreign key relationships.
- Exploring patient and hospital data.
- Analyzing encounters, conditions, medications, procedures, and other healthcare records.
- Performing aggregate and advanced analytical queries.

## Execution Order

Execute the SQL scripts in the following order:

1. `01_Create_Database.sql`
2. `02_Create_Tables.sql`
3. `03_Load_Data.sql` (if required)
4. `04_Basic_Analysis.sql`
5. `05_Advanced_Analysis.sql`

**Note:** The data-loading method may depend on how the cleaned datasets were imported into MySQL. Update any file paths or loading instructions as required.
