/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL-- Si esta tabla ya existe, elìminala antes de volver a crearla 
    DROP TABLE bronze.crm_cust_info;
GO
CREATE TABLE bronze.crm_cust_info(
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_first_name NVARCHAR(50),
    cst_last_name NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date NVARCHAR(50)-- Se coloca para eitar que no carge los datos con formato de fechas erroneos

)

IF OBJECT_ID('bronze.crm_prd_info','U') IS NOT NULL 
       DROP TABLE bronze.crm_prd_info
CREATE TABLE bronze.crm_prd_info (
       prd_id INT,
       prd_key NVARCHAR(50),
       prd_nm NVARCHAR(50),
       prd_cost INT,
       prd_line NVARCHAR(50),
       prd_start_dt NVARCHAR(50),
       prd_end_dt NVARCHAR(50)
)

IF OBJECT_ID ('bronze.crm_sales_details', 'U') IS NOT NULL 
    DROP TABLE bronze.crm_sales_details

CREATE TABLE bronze.crm_sales_details (
       sls_ord_num NVARCHAR(50),
       sls_prd_key NVARCHAR(50),
       sls_cust_id INT,
       sls_order_dt NVARCHAR(50),
       sls_ship_dt NVARCHAR(50),
       sls_due_dt NVARCHAR(50),
       sls_sales INT,
       sls_quantity INT,
       sls_price INT
)

IF OBJECT_ID ('bronze.erp_CUST_AZ12', 'U') IS NOT NULL 
    DROP TABLE bronze.erp_CUST_AZ12

CREATE TABLE bronze.erp_CUST_AZ12 (
        cid NVARCHAR(50),
        bdate NVARCHAR(50),
        gen NVARCHAR(50)

)
IF OBJECT_ID('bronze.erp_LOC_A101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_LOC_A101

CREATE TABLE bronze.erp_LOC_A101 (
        cid NVARCHAR(50),
        cntry NVARCHAR(50)
)

IF OBJECT_ID('bronze.erp_PX_CAT_G1V2', 'U') IS NOT NULL
     DROP TABLE bronze.erp_PX_CAT_G1V2

CREATE TABLE bronze.erp_PX_CAT_G1V2(
         id NVARCHAR(50),
         cat NVARCHAR(50),
         subcat NVARCHAR(50),
         maintenance NVARCHAR(50)
        
)
-- Este query para verificar el nombre de las tablas en el esquema bronze
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'bronze';
-- Este query para verificar los nombres, las columnas y tipo de datos
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze'
ORDER BY TABLE_NAME, ORDINAL_POSITION;
