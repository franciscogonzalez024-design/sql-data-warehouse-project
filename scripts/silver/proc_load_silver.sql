/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

EXECUTE silver.load_silver


CREATE OR ALTER PROCEDURE silver.load_silver AS

BEGIN

	DECLARE @start_time DATETIME,@end_time DATETIME, @batch_start_time DATETIME,@batch_end_time DATETIME
	BEGIN TRY

	 SET @batch_start_time = GETDATE();
			PRINT '================================================';
			PRINT 'Loading Silver Layer';
			PRINT '================================================';

			PRINT '------------------------------------------------';
			PRINT 'Loading CRM Tables';
			PRINT '------------------------------------------------';
			-- Proceso para insertar en silver.crm_cust_info 
			SET @start_time =GETDATE()
			PRINT' >>Truncating silver.crm_cust_info';
			TRUNCATE TABLE silver.crm_cust_info;
			PRINT' >>Inserting silver.crm_cust_info';
			INSERT INTO silver.crm_cust_info (
				cst_id,
				cst_key,
				cst_first_name,
				cst_last_name,
				cst_marital_status,
				cst_gndr,
				cst_create_date
			)

			SELECT 
				cst_id,
				TRIM(cst_key) cst_key,
				TRIM(cst_first_name) cst_first_name,
				TRIM(cst_last_name) cst_last_name,
				CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
					 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
					 ELSE 'N/A' END  cst_marital_status,--Normalizar el status para que sea legible
				CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
					 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
					 ELSE 'N/A' END  cst_gndr,--Normalizar el status para que sea legible
				TRY_CAST(NULLIF(TRIM(cst_create_date),'') AS DATE) cst_create_date--Toma cst_create_date, quítale espacios, si queda vacío trátalo como nulo, e intenta convertirlo a fecha; si no se puede, devuelve null.

			FROM (
				SELECT *,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY TRY_CAST(cst_create_date AS DATE) DESC) flag_last-- SE UTILIZA TRY CAST POR SI VIENEN FORMATOS DISTINTOS Y NO PUEDEN CONVERTISE EN FECHA
				FROM bronze.crm_cust_info
				WHERE cst_id IS NOT NULL
				) t WHERE flag_last = 1--se toma el valor mas reciente 
			SET @end_time=GETDATE()
			PRINT '>> Load duration: '+ CAST( DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
			PRINT '>> -------------'


			-- Proceso para insertar en silver.crm_prd_info
			SET @start_time = GETDATE()
			PRINT' >>Truncating silver.crm_prd_info';
			TRUNCATE TABLE silver.crm_prd_info;
			PRINT' >>Inserting silver.crm_prd_info';
			INSERT INTO silver.crm_prd_info(
					prd_id,
					cat_id,
					prd_key,
					prd_nm,
					prd_cost,
					prd_line,
					prd_start_dt,
					prd_end_dt
			)
			SELECT 
				prd_id,
				REPLACE(SUBSTRING(prd_key,1,5),'-','_') cat_id,-- SE TOMA DEL 1 5 DIGITOS DE LA COLUMNA INICIAL PRD_KEY LO CUAL TIENE RELACION CON LA TABLA bronze.erp_PX_CAT_G1V2 
				SUBSTRING(prd_key,7,LEN(prd_key)) prd_key,-- SE TOMA LA SEGUNDA PARTE DE AL COLUMNA PRD_KEY LO CUAL TIENE RELACION CON LA TABLA bronze.crm_sales_details
				TRIM(prd_nm) prd_nm,
				COALESCE(prd_cost,0) prd_cost,
				CASE
					WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
					WHEN UPPER(TRIM(prd_line))  = 'R' THEN 'Road'
					WHEN UPPER(TRIM(prd_line))  = 'S' THEN 'Other Sales'
					WHEN UPPER(TRIM(prd_line))  = 'T' THEN 'Touring'
					ELSE 'N/A'
					END prd_line,
				TRY_CAST(prd_start_dt AS DATE) prd_start_dt,
				DATEADD(
					DAY,-1,
						LEAD(TRY_CAST(prd_start_dt AS DATE)) OVER(PARTITION BY prd_key ORDER BY TRY_CAST(prd_start_dt AS DATE )) 
						)prd_end_dt-- se calcula la fecha final como un dia antes de la siguiente fecha de inicio
			FROM bronze.crm_prd_info
			SET @end_time = GETDATE()
			PRINT '>> Load duration: '+ CAST( DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
			PRINT '>> -------------'

			-- Proceso para insertar en silver.crm_sales_details
			SET @start_time = GETDATE();
			PRINT' >>Truncating silver.crm_sales_details';
			TRUNCATE TABLE silver.crm_sales_details;
			PRINT' >>Inserting silver.crm_sales_details';
			INSERT INTO silver.crm_sales_details(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price

			)
			SELECT 
				TRIM(sls_ord_num) sls_ord_num,
				TRIM(sls_prd_key) sls_prd_key,
				sls_cust_id,
				CASE WHEN 
							TRIM(sls_order_dt) = '' 
							OR TRIM(sls_order_dt) ='0'
							OR LEN(TRIM(sls_order_dt)) != 8 THEN NULL
					ELSE CAST(sls_order_dt AS DATE) 
				END sls_order_dt,
					CASE WHEN 
							TRIM(sls_ship_dt) = '' 
							OR TRIM(sls_ship_dt) ='0'
							OR LEN(TRIM(sls_ship_dt)) != 8 THEN NULL
					ELSE CAST(sls_ship_dt AS DATE) 
				END sls_ship_dt,
					CASE WHEN 
							TRIM(sls_due_dt) = '' 
							OR TRIM(sls_due_dt) ='0'
							OR LEN(TRIM(sls_due_dt)) != 8 THEN NULL
					ELSE CAST(sls_due_dt AS DATE) 
				END sls_due_dt,
				CASE WHEN sls_sales IS NULL OR sls_sales<=0 OR sls_sales != sls_quantity *ABS(sls_price)
					 THEN sls_quantity *ABS(sls_price)
					ELSE sls_sales
				END sls_sales,
				sls_quantity,
				CASE WHEN sls_price IS NULL OR sls_price<=0 
					 THEN  sls_sales/ NULLIF(sls_quantity,0)
					ELSE sls_price
				END sls_price
			FROM bronze.crm_sales_details
			SET @end_time=GETDATE();
			PRINT '>> Load duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
			PRINT '>> -------------'

			-- Proceso para insertar en silver.erp_CUST_AZ12
			SET @start_time = GETDATE()
			PRINT' >>Truncating silver.erp_CUST_AZ12';
			TRUNCATE TABLE silver.erp_CUST_AZ12;
			PRINT' >>Inserting silver.erp_CUST_AZ12';
			INSERT INTO silver.erp_CUST_AZ12(
				cid,
				bdate,
				gen
			)
			SELECT 
				CASE WHEN UPPER(TRIM(cid)) LIKE 'NAS%' THEN SUBSTRING(cid,4,len(cid))-- se remueve el prefijo NAS
				ELSE cid 
				END cid,
				CASE WHEN TRY_CAST(NULLIF(TRIM(bdate),'') AS DATE) > GETDATE() THEN NULL -- fechas despues de hoy se colocan null
					 ELSE TRY_CAST(NULLIF(TRIM(bdate),'') AS DATE)
					 END bdate,
					 CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
						  WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
						  ELSE 'N/A'-- se normalizan valores de genero y se manejan valores desconocidos como N/A
						  END gen
			FROM bronze.erp_CUST_AZ12
			SET @end_time= GETDATE()
			PRINT '>> Load duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
			PRINT '>> -------------'

			-- Proceso para insertar en silver.erp_LOC_A101
			SET @start_time = GETDATE()
			PRINT' >>Truncating silver.erp_LOC_A101';
			TRUNCATE TABLE silver.erp_LOC_A101;
			PRINT' >>Inserting silver.erp_LOC_A101';
			INSERT INTO silver.erp_LOC_A101 (
				cid,
				cntry

			)

			SELECT 
				REPLACE(cid,'-','') cid,
				CASE WHEN UPPER(TRIM(cntry)) IN ('USA','US') THEN 'United States'
						 WHEN UPPER(TRIM(cntry)) IN ('DE') THEN 'Germany'
						 WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'N/A'
						 ELSE TRIM(cntry)
						 END  cntry--Se normalizan valores y se manejan valores vacíos
			FROM bronze.erp_LOC_A101
			SET @end_time = GETDATE()
			PRINT '>> Load duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
			PRINT '>> -------------'
			-- Proceso para insertar en silver.erp_LOC_A101
			SET @start_time = GETDATE()
			PRINT' >>Truncating silver.erp_PX_CAT_G1V2';
			TRUNCATE TABLE silver.erp_PX_CAT_G1V2;
			PRINT' >>Inserting silver.erp_PX_CAT_G1V2';
			INSERT INTO silver.erp_PX_CAT_G1V2 (
				id,
				cat,
				subcat,
				maintenance	

			)
			SELECT 
					id,
					cat,
					subcat,
					maintenance
			FROM bronze.erp_PX_CAT_G1V2
			SET @end_time = GETDATE()
				PRINT '>> Load duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
			PRINT '>> -------------'

			SET @batch_end_time = GETDATE();
			PRINT '=========================================='
			PRINT 'Loading Silver Layer is Completed';
			PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
			PRINT '=========================================='
		END TRY 
		BEGIN CATCH 
			PRINT '=========================================='
			PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
			PRINT 'Error Message' + ERROR_MESSAGE();
			PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
			PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
			PRINT '=========================================='
		END CATCH
	END











