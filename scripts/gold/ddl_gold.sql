/*
==============================================================================
DDL Script: Create Gold Views
==============================================================================
Script Purpose:
  This script creates views for the Gold layer in the data warehouse.
  The Gold layer represents the final dimension and fact tables (Star Schema)

  Each view performs transformations and combines data from the Silver layer 
  to produce a clean,enriched,integrated and business-ready dataset.

Usage:
  - These views can be queried directly for analytics and reporting.
==============================================================================
*/


--===============================================
--Create Dimension: Gold.dim_customers
--===============================================
IF OBJECT_ID('Gold.dim_customers','V') IS NOT NULL
  DROP VIEW Gold.dim_customers;
GO
CREATE VIEW Gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY cst_id) AS cst_key,
	ci.cst_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname,
	ci.cst_lastname,
	la.cntry AS Country,
	ci.cst_marital_status,
	CASE WHEN ci.cst_gndr!='Unknown' THEN ci.cst_gndr 
		 ELSE COALESCE(ca.gen,'N/A')
    END as new_gen,
	ca.bdate,
	ci.cst_create_date
FROM Silver.crm_cust_info ci
LEFT JOIN Silver.erp_cust_az12 ca
ON        ci.cst_key=ca.cid
LEFT JOIN Silver.erp_loc_a101 la
ON        ci.cst_key=la.cid
;
--===============================================
--Create Dimension: Gold.dim_products
--===============================================
IF OBJECT_ID('Gold.dim_products','V') IS NOT NULL
  DROP VIEW Gold.dim_products;
GO
CREATE VIEW Gold.dim_products AS 
SELECT 
	ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt,pn.prd_key) AS product_key,
	pn.prd_id,
	pn.prd_key,
	pn.prd_nm,
	pn.cat_id,
	pc.cat,
	pc.subcat,
	pc.maintenance,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt
FROM Silver.crm_prd_info pn
LEFT JOIN Silver.erp_px_cat_g1v2 pc
ON        pn.cat_id=pc.id
WHERE prd_end_dt IS NULL
;  
--===============================================
--Create Dimension: Gold.fact_sales
--===============================================
IF OBJECT_ID('Gold.fact_sales','V') IS NOT NULL
  DROP VIEW Gold.fact_sales;
GO
CREATE VIEW Gold.fact_sales AS
SELECT 
  sd.sales_ord_num,
  pr.product_key,
  cu.cst_key,
  sd.sls_order_dt,
  sd.sls_ship_dt,
  sd.sls_due_dt,
  sd.sls_sales,
  sd.sls_qty,
  sd.sls_price
FROM Silver.crm_sales_details sd
LEFT JOIN Gold.dim_products pr
ON sd.sls_prd_key=pr.prd_key
LEFT JOIN Gold.dim_customers cu
ON        sd.sls_cust_id=cu.cst_id;




