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



	



