/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
SCRIPT PURPOSE:
	This script creates tables in the 'bronze' schema, dropping existing tables 
	if they already exists.
	Run this script to re-define the DDL structure of 'bronze' Tables
STORED PROCEDURE: LOAD BRONZE LAYER WITH NO PARAMETERS (SOURCE -> BRONZE) 
>> It truncate the existing tables and then insert data into them.
>> Uses bulk insert command to load data in one go from sources (crm & erp files)
USAGE EXAMPLE:
	EXEC Bronze.load_bronze;
===============================================================================
*/
--Create All Tables from sources (crm & erp)
IF OBJECT_ID ('Bronze.crm_cust_info','U') IS NOT NULL
	DROP TABLE Bronze.crm_cust_info;
CREATE TABLE Bronze.crm_cust_info(
	cst_id				INT,
	cst_key				NVARCHAR(50),
	cst_firstname		NVARCHAR(50),
	cst_lastname		NVARCHAR(50),
	cst_marital_status  NVARCHAR(50),
	cst_gndr			NVARCHAR(50),
	cst_create_date		DATE
);
IF OBJECT_ID ('Bronze.crm_prd_info','U') IS NOT NULL
	DROP TABLE Bronze.crm_prd_info;
Create Table Bronze.crm_prd_info(
	prd_id		 INT,
	prd_key		 NVARCHAR(50),
	prd_nm		 NVARCHAR(50),
	prd_cost	 INT,
	prd_line	 NVARCHAR(50),
	prd_start_dt DATETIME,
	prd_end_dt   DATETIME 
);
IF OBJECT_ID ('Bronze.crm_sales_details','U') IS NOT NULL
	DROP TABLE Bronze.crm_sales_details;
CREATE TABLE Bronze.crm_sales_details(
	sales_ord_num NVARCHAR(50),
	sls_prd_key   NVARCHAR(50),
	sls_cust_id	  INT,
	sls_order_dt  INT,
	sls_ship_dt   INT,
	sls_due_dt    INT,
	sls_sales     INT,
	sls_qty		  INT,
	sls_price	  INT
);
IF OBJECT_ID ('Bronze.erp_loc_a101','U') IS NOT NULL
	DROP TABLE Bronze.erp_loc_a101 ;
CREATE TABLE Bronze.erp_loc_a101(
	cid   NVARCHAR(50),
	cntry NVARCHAR(50)
);
IF OBJECT_ID ('Bronze.erp_cust_az12','U') IS NOT NULL
	DROP TABLE Bronze.erp_cust_az12;
CREATE TABLE Bronze.erp_cust_az12(
	cid		 NVARCHAR(50),
	bdate	 DATE,
	gen		 NVARCHAR(50)
	
);
IF OBJECT_ID ('Bronze.erp_px_cat_g1v2','U') IS NOT NULL
	DROP TABLE Bronze.erp_px_cat_g1v2;
CREATE TABLE Bronze.erp_px_cat_g1v2(
	id			NVARCHAR(50),
	cat			NVARCHAR(50),
	subcat		NVARCHAR(50),
	maintenance NVARCHAR(50)
);

-- INSERTING DATA INTO ALL CREATED TABLES
CREATE OR ALTER PROCEDURE Bronze.load_bronze AS 
BEGIN
	DECLARE @start_time DATETIME, @end_time	DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	SET @batch_start_time=GETDATE();
	BEGIN TRY
		PRINT '=============================================='
		PRINT 'Loading Bronze'
		PRINT '=============================================='
		PRINT '------------------------------------------------'
		PRINT 'Loading CRM tables'
		PRINT '------------------------------------------------'
		SET @start_time=GETDATE();

		PRINT '>> TRUNCATING TABLE: Bronze.crm_cust_info';
		TRUNCATE TABLE Bronze.crm_cust_info; 
		PRINT '>> INSERTING DATA INTO:Bronze.crm_cust_info';
		BULK INSERT Bronze.crm_cust_info
		FROM 'C:\Users\ANUBHAV SHUKLA\OneDrive\Attachments\cust_info.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
			SET @end_time=GETDATE()
			PRINT 'LOAD DURATION:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+'SECONDS';
        PRINT '-----------------------------------------------------'
		SET @start_time=GETDATE()
		
		PRINT'>> TRUNCATING TABLE: Bronze.crm_prd_info';
		TRUNCATE TABLE Bronze.crm_prd_info;
		PRINT '>> INSERTING DATA INTO:Bronze.crm_prd_info';
		BULK INSERT Bronze.crm_prd_info
		FROM 'C:\Users\ANUBHAV SHUKLA\OneDrive\Attachments\prd_info.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @end_time=GETDATE()
		PRINT 'LOAD DURATION:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+'SECONDS';
		PRINT '-----------------------------------------------------'
		SET @start_time=GETDATE()
		PRINT '>> TRUNCATING TABLE: Bronze.crm_sales_details';
		TRUNCATE TABLE Bronze.crm_sales_details;
		PRINT '>> INSERTING INTO TABLE: Bronze.crm_sales_details'
		BULK INSERT Bronze.crm_sales_details
		FROM 'C:\Users\ANUBHAV SHUKLA\OneDrive\Attachments\sales_details.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @end_time=GETDATE()
		PRINT 'LOAD DURATION:'+ CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR)+'SECONDS';
		PRINT '-----------------------------------------------------'
		SET @start_time=GETDATE()

		PRINT '>> TRUNCATING TABLE:Bronze.erp_cust_az12';
		TRUNCATE TABLE Bronze.erp_cust_az12;
		PRINT '>> INSERTING INTO TABLE:Bronze.erp_cust_az12';
		BULK INSERT Bronze.erp_cust_az12
		FROM 'C:\Users\ANUBHAV SHUKLA\OneDrive\Attachments\CUST_AZ12.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @end_time=GETDATE()
		PRINT 'LOAD DURATION:'+ CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR)+'SECONDS';
		PRINT '-----------------------------------------------------'
		SET @start_time=GETDATE()

		PRINT '>> TRUNCATING TABLE: Bronze.erp_loc_a101';
		TRUNCATE TABLE Bronze.erp_loc_a101;
		PRINT '>> INSERTING INTO: Bronze.erp_loc_a101';
		BULK INSERT Bronze.erp_loc_a101
		FROM 'C:\Users\ANUBHAV SHUKLA\OneDrive\Attachments\LOC_A101.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @end_time=GETDATE()
		PRINT 'LOAD DURATION:'+ CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR)+'SECONDS';
		PRINT '-----------------------------------------------------'
		SET @start_time=GETDATE()
		PRINT'>> TRUNCATING TABLE: Bronze.erp_px_cat_g1v2'
		TRUNCATE TABLE Bronze.erp_px_cat_g1v2;
		BULK INSERT Bronze.erp_px_cat_g1v2
		FROM 'C:\Users\ANUBHAV SHUKLA\OneDrive\Documents\temp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @end_time=GETDATE()
		PRINT 'LOAD DURATION:'+ CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR)+'SECONDS';
		PRINT '-----------------------------------------------------'
		END TRY
		BEGIN CATCH
		PRINT '============================'
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message'+ERROR_MESSAGE();
		PRINT 'Error Message'+CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message'+CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '============================='
		END CATCH;
		SET @batch_end_time=GETDATE()
		PRINT'TIME TAKEN BY WHOLE BATCH IS:'+CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR)+'SECOND';
END;
