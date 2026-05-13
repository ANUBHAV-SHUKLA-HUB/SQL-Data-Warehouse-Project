/*
=============================================================================
STORED PROCEDURE: Load Silver Layer (Bronze -> Silver)
=============================================================================
Script Purpose:
  This stored procedure performs the ETL(Extract, transform,Load) process to
  populate the 'Silver' schema tables from the 'Bronze' schema.
ACTIONS PERFORMED:
  -Truncates Silver tables
  -Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters;
  None.
  This stored procedure does not accept any parameters or return any values.
Usage Example:
    EXEC Silver.load_silver
================================================================================
*/

CREATE OR ALTER PROCEDURE Silver.load_silver AS 
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME,@batch_end_time DATETIME; 
	BEGIN TRY
		SET @batch_start_time=GETDATE()
		PRINT '==============================================';
		PRINT 'Loading Silver layer';
		PRINT '==============================================';
		PRINT '-----------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '-----------------------------------------------';

		SET @start_time=GETDATE()
		TRUNCATE TABLE Silver.crm_cust_info
		PRINT '>> Inserting Data Into: Silver.crm_cust_info';
		INSERT INTO Silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)
		select 
		cst_id,
		cst_key,
		trim(cst_firstname) as cst_firstname,
		trim(cst_lastname) as cst_lastname,
		CASE WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single'
			 WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Married'
			 ELSE 'Unknown'
		END cst_marital_status,
		CASE WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female'
			 WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male'
			 ELSE 'Unknown'
		END cst_gndr,
		cst_create_date
		from
		(select 
		*,
		row_number() over (partition by cst_id order by cst_create_date desc) as rn
		from Bronze.crm_cust_info)t
		where rn=1;
		SET @end_time=GETDATE()
		
		PRINT 'LOAD DURATION:'+ CAST(DATEDIFF(SECOND,@start_time,@end_time)AS VARCHAR)+'SECONDS';
		PRINT'=============================================='
		PRINT 'LOADING Silver.crm_prd_info'
		PRINT'=============================================='

		SET @start_time=GETDATE()
		TRUNCATE TABLE Silver.crm_prd_info
		PRINT '>> Inserting Data Into: Silver.crm_prd_info';
		INSERT INTO Silver.crm_prd_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		select 
		prd_id, 
		Replace(substring(prd_key,1,5),'-','_') as cat_id,
		substring(prd_key,7,len(prd_key)) as prd_key,
		prd_nm,
		ISNULL(prd_cost,0) as prd_cost,
		CASE UPPER(TRIM(prd_line))
			WHEN 'R' THEN 'ROAD'
			WHEN 'S' THEN 'OTHER SALES'
			WHEN 'M' THEN 'MOUNTAIN'
			WHEN 'T' THEN 'TOURING'
			ELSE 'Unknown'
			END as prd_line,
		CAST(prd_start_dt as DATE) as prd_start_dt,
		CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 as DATE) as prd_end_dt
		from Bronze.crm_prd_info;
		SET @end_time=GETDATE()
		
		PRINT 'LOAD DURATION:'+ CAST(DATEDIFF(SECOND,@start_time,@end_time)AS VARCHAR)+'SECONDS';
		PRINT'=============================================='
		PRINT 'LOADING Silver.crm_sales_details'
		PRINT'=============================================='

		SET @start_time=GETDATE()
		TRUNCATE TABLE Bronze.crm_sales_details
		PRINT '>> Inserting Data Into: Silver.crm_sales_details';
		INSERT INTO Silver.crm_sales_details (
			sales_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_qty,
			sls_price
		)
		SELECT
		sales_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE WHEN sls_order_dt=0 OR LEN(sls_order_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		END as sls_order_dt,
		CASE WHEN sls_ship_dt=0 OR LEN(sls_ship_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		END as sls_ship_dt,
		CASE WHEN sls_due_dt=0 OR LEN(sls_due_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		END as sls_due_dt,
		CASE WHEN sls_sales IS NULL OR sls_sales<=0 OR sls_sales !=sls_qty*ABS(sls_price)
			THEN sls_qty*ABS(sls_price)
			ELSE sls_sales 
		END sls_sales,
		sls_qty,
		CASE WHEN sls_price IS NULL OR sls_price<=0
			THEN sls_sales/NULLIF(sls_qty,0)
			ELSE sls_price
		END sls_price
		FROM Bronze.crm_sales_details;
		SET @end_time=GETDATE()
		
		PRINT 'LOAD DURATION:'+ CAST(DATEDIFF(SECOND,@start_time,@end_time)AS VARCHAR)+'SECONDS';
		PRINT'=============================================='
		PRINT 'LOADING Silver.erp_cust_az12'
		PRINT'=============================================='

		SET @start_time=GETDATE()
		TRUNCATE TABLE Silver.erp_cust_az12
		PRINT '>> Inserting Data Into: Silver.erp_cust_az12';

		INSERT INTO Silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)
		SELECT 
		CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
			ELSE cid
		END cid, 
		CASE WHEN bdate> GETDATE() THEN NULL
			ELSE bdate
		END bdate,
		CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
			WHEN UPPER(TRIM(gen)) IN ('m','MALE') THEN 'Male'
			ELSE 'N/A'	
		END gen
		FROM Bronze.erp_cust_az12;
		SET @end_time=GETDATE()
		PRINT 'LOAD DURATION:'+ CAST(DATEDIFF(SECOND,@start_time,@end_time)AS VARCHAR)+'SECONDS';
		PRINT'=============================================='
		PRINT 'LOADING Silver.erp_loc_a101'
		PRINT'=============================================='

		SET @start_time=GETDATE()
		TRUNCATE TABLE Silver.erp_loc_a101
		PRINT '>> Inserting Data Into: Silver.erp_loc_a101';
		INSERT INTO Silver.erp_loc_a101(
			cid,
			cntry
		)
		SELECT 
		REPLACE (cid, '-','') as cid,
		CASE WHEN UPPER(TRIM(cntry)) IN ('DE','GERMANY') THEN 'Germany'
			WHEN UPPER(TRIM(cntry)) IN ('US','USA','UNITED STATES') THEN 'United States'
			WHEN UPPER(TRIM(cntry)) IS NULL OR UPPER(TRIM(cntry))='' THEN 'N/A'
			ELSE TRIM(cntry)
		END cntry
		FROM Bronze.erp_loc_a101;
		SET @end_time=GETDATE()
		PRINT 'LOAD DURATION:'+ CAST(DATEDIFF(SECOND,@start_time,@end_time)AS VARCHAR)+'SECONDS';
		PRINT'=============================================='
		PRINT 'LOADING Silver.erp_px_cat_g1v2'
		PRINT'=============================================='
		SET @start_time=GETDATE()
		TRUNCATE TABLE Silver.erp_px_cat_g1v2
		PRINT '>> Inserting Data Into: Silver.erp_px_cat_g1v2';
		INSERT INTO Silver.erp_px_cat_g1v2(
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
		FROM Bronze.erp_px_cat_g1v2;
		SET @end_time=GETDATE()
		PRINT 'LOAD DURATION:'+ CAST(DATEDIFF(SECOND,@start_time,@end_time)AS VARCHAR)+'SECONDS';
		PRINT '=============================================='
		PRINT 'LOADING SILVER LAYER IS COMPLETED'
		SET @batch_end_time=GETDATE()
		PRINT 'TOTAL LOAD DURATION:'+CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR)+'SECONDS'
		PRINT '==============================================='

	END TRY
	BEGIN CATCH
	PRINT '================================================='
	PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
	PRINT 'ERROR MESSAGE'+ERROR_MESSAGE();
	PRINT 'ERROR MESSAGE'+CAST(ERROR_NUMBER() AS NVARCHAR);
	PRINT 'ERROR MESSAGE'+CAST(ERROR_STATE() AS NVARCHAR);
	PRINT '================================================='
	END CATCH
END;


