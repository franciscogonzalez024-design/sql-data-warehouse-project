/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
     DECLARE @start_time DATETIME,@end_time DATETIME, @batch_start_time DATETIME,@batch_end_time DATETIME
     BEGIN TRY 
        SET @batch_start_time = GETDATE()
        PRINT'==========================================================='
        PRINT'Loading Bronze Layer'
        PRINT'==========================================================='
        
        PRINT'-----------------------------------------------------------'
        PRINT'Loading CRM Tables'
        PRINT'-----------------------------------------------------------'

        SET @start_time = GETDATE();
        PRINT'>> Truncating Table: bronze.crm_cust_info '
        TRUNCATE TABLE bronze.crm_cust_info
        PRINT'>> Inserting Data Into: Table: bronze.crm_cust_info '
        BULK INSERT  bronze.crm_cust_info
        FROM 'C:\Users\50767\OneDrive - Ensa\Documentos\Cursos\SQL\Proyecto SQL Baraa\crm\cust_info.csv'
        WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR=',',
                TABLOCK
        )
         SET @end_time = GETDATE();
         PRINT '>> Loading duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
         PRINT '>>--------------------------------'

        SET @start_time = GETDATE();
        PRINT'>> Truncating Table: bronze.crm_prd_info '
        TRUNCATE TABLE bronze.crm_prd_info
        PRINT'>> Inserting Data Into: Table: bronze.crm_prd_info '
        BULK INSERT  bronze.crm_prd_info
        FROM 'C:\Users\50767\OneDrive - Ensa\Documentos\Cursos\SQL\Proyecto SQL Baraa\crm\prd_info.csv'
        WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR=',',
                TABLOCK
        )
         SET @end_time = GETDATE();
         PRINT '>> Loading duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
         PRINT '>>--------------------------------'

        SET @start_time = GETDATE();
        PRINT'>> Truncating Table: bronze.crm_sales_details '
        TRUNCATE TABLE bronze.crm_sales_details
        PRINT'>> Inserting Data Into: Table: bronze.crm_sales_details '
        BULK INSERT  bronze.crm_sales_details
        FROM 'C:\Users\50767\OneDrive - Ensa\Documentos\Cursos\SQL\Proyecto SQL Baraa\crm\sales_details.csv'
        WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR=',',
                TABLOCK
        )
         SET @end_time = GETDATE();
         PRINT '>> Loading duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
         PRINT '>>--------------------------------'


        SET @start_time = GETDATE();
        PRINT'>> Truncating Table: bronze.erp_CUST_AZ12 '
        TRUNCATE TABLE bronze.erp_CUST_AZ12
        PRINT'>> Inserting Data Into: Table: bronze.erp_CUST_AZ12 '
        BULK INSERT  bronze.erp_CUST_AZ12
        FROM 'C:\Users\50767\OneDrive - Ensa\Documentos\Cursos\SQL\Proyecto SQL Baraa\erp\CUST_AZ12.csv'
        WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR=',',
                TABLOCK
        )
         SET @end_time = GETDATE();
         PRINT '>> Loading duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
         PRINT '>>--------------------------------'


        PRINT'-----------------------------------------------------------'
        PRINT'Loading CRM Tables'
        PRINT'-----------------------------------------------------------'

        SET @start_time = GETDATE();
        PRINT'>> Truncating Table: bronze.erp_LOC_A101 '
        TRUNCATE TABLE bronze.erp_LOC_A101
        PRINT'>> Inserting Data Into: Table: bronze.erp_LOC_A101 '
        BULK INSERT  bronze.erp_LOC_A101
        FROM 'C:\Users\50767\OneDrive - Ensa\Documentos\Cursos\SQL\Proyecto SQL Baraa\erp\LOC_A101.csv'
        WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR=',',
                TABLOCK
        )
         SET @end_time = GETDATE();
         PRINT '>> Loading duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
         PRINT '>>--------------------------------'


        SET @start_time = GETDATE();
        PRINT'>> Truncating Table: bronze.erp_PX_CAT_G1V2 '
        TRUNCATE TABLE bronze.erp_PX_CAT_G1V2
        PRINT'>> Inserting Data Into: Table: bronze.erp_PX_CAT_G1V2 '
        BULK INSERT  bronze.erp_PX_CAT_G1V2
        FROM 'C:\Users\50767\OneDrive - Ensa\Documentos\Cursos\SQL\Proyecto SQL Baraa\erp\PX_CAT_G1V2.csv'
        WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR=',',
                TABLOCK
        )

         SET @end_time = GETDATE();
         PRINT '>> Loading duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
         PRINT '>>--------------------------------'

        SET @batch_end_time = GETDATE();
        PRINT '=========================================='
		PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='

    END TRY
    BEGIN CATCH--Catch sirve para hacer que pasa si falla el TRY
        PRINT '===========================================================';
        PRINT 'ERROR OCCURRED WHILE LOADING BRONZE LAYER';
        PRINT '===========================================================';
        PRINT 'Error message: ' + ERROR_MESSAGE();--Da el texto real del error
        PRINT 'Error number: ' + CAST(ERROR_NUMBER() AS VARCHAR(20));--Da el codigo de error
        PRINT 'Error line: ' + CAST(ERROR_LINE() AS VARCHAR(20));--Da la linea que tuvo el error 
        PRINT 'Procedure name: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');--Nombre del procedure donde ocurriò
    END CATCH
END

EXECUTE bronze.load_bronze

-- Esta query valida si hay vacios o nulos en la columna
SELECT COUNT(*), 
       SUM(CASE WHEN cst_id IS NULL THEN 1 ELSE 0 END) cst_id_nulos,
       SUM(CASE WHEN cst_key IS NULL OR  LTRIM(RTRIM(cst_key))= '' THEN 1 ELSE 0 END) cst_key_vacios,
       SUM(CASE WHEN cst_first_name IS NULL OR  LTRIM(RTRIM(cst_first_name))= '' THEN 1 ELSE 0 END) cst_first_name_vacios,
       SUM(CASE WHEN cst_last_name IS NULL OR  LTRIM(RTRIM(cst_last_name))= '' THEN 1 ELSE 0 END) cst_last_name_vacios,
       SUM(CASE WHEN cst_marital_status IS NULL OR LTRIM(RTRIM(cst_marital_status)) = '' THEN 1 ELSE 0 END) AS cst_marital_status_vacios,
       SUM(CASE WHEN cst_gndr IS NULL OR LTRIM(RTRIM(cst_gndr)) = '' THEN 1 ELSE 0 END) AS cst_gndr_vacios,
       SUM(CASE WHEN cst_create_date IS NULL OR LTRIM(RTRIM(cst_create_date)) = '' THEN 1 ELSE 0 END) AS cst_create_date_nulos
FROM bronze.crm_cust_info

--Esta query valida si la fecha es correcta, solo cuenta los valores sucios de fecha, excluye los nulos vacìos y espacios
SELECT 

        SUM(CASE 
            WHEN TRY_CAST(cst_create_date AS DATE) IS NULL--Intenta convertir el valor de la columna a fecha 
                 AND cst_create_date IS NOT NULL--evita contar los valores que ya vienen con null en la carga
                 AND LTRIM(RTRIM(cst_create_date)) <> ''--Esto evita contar strings vacíos o con solo espacios.
            THEN 1
            ELSE 0
        END) AS fechas_invalidas
FROM bronze.crm_cust_info


