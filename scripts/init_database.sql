/*
==============================================
Create Database and Schemas
==============================================
Script Purpose:
  This script creates a new database named 'DataWarehouse' after checking if it already exists.
  If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
  within the database:'Bronze','Silver' and 'Gold'.
WARNING:
  Running this script will drop the entire 'DataWarehouse' database if it exists.
  All data in the database will be permanently deleted. Proceed with caution
  and ensure you have proper backups before running this script.
*/
use master;
GO
--Drop and recreate the 'DataWarehouse' database
IF EXISTS(SELECT 1 FROM sys.databases where name='DataWarehouse')
BEGIN
	alter database DataWarehouse set SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO
-- CREATE THE 'DataWarehouse' DATABASE
Create Database DataWarehouse;
GO
USE DataWarehouse;
GO
-- Create Schemas
Create Schema Bronze;
GO
Create Schema Silver;
GO
Create Schema Gold;
GO
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

	



