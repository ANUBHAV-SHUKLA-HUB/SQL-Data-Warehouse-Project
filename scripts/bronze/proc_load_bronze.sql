/*
======================================================================
STORED PROCEDURE: LOAD BRONZE LAYER (SOURCE -> BRONZE)
======================================================================
SCRIPT PURPOSE:
  This stored procedure loads data into the 'bronze' schema from external  CSV files.
  It performs the following actions:
  -Truncates the bronze tables before loading data.
  -Uses the 'Bulk insert' command to load data from CSV files to bronze tables.
There are no parameters used.
Used Example:
  EXEC Bronze.load_bronze;
*/
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















