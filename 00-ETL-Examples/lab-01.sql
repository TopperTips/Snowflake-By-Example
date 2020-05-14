-- Lab 01

-- Create a data base

CREATE DATABASE TIPS_SALES_PROD 
COMMENT = 'This is topper tips sales production database';


-- Create Schema
CREATE SCHEMA "TIPS_SALES_PROD"."SALES" 
COMMENT = 'This is TopperTips Sales Data';

-- Created a names internal stage
CREATE STAGE "TIPS_SALES_PROD"."SALES".SALES_STAGE 
COMMENT = 'This is named internal SF manage stage';

--Creating a stage via clone (this operation may not work with WebUI)
CREATE STAGE TIPS_SALES_PROD.SALES.S3 
CLONE USDA_NUTRIENT_STDREF.PUBLIC.S3_USDF_EXTERNAL_NAMED_STAGE 
COMMENT = 'Cloning USDF S3 Bucket';


-- Creating a part table
CREATE TABLE TIPS_SALES_PROD.SALES.PART 
CLONE SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART 
COMMENT = 'This is cloned table from TPC AdHoc SF1';

-- <Error> SQL compilation error: Cannot clone from a table that was imported from a share.

-- alternative is -- use create like
CREATE TABLE TIPS_SALES_PROD.SALES.PART  LIKE SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART 
COMMENT = 'This is create like  table from TPC AdHoc SF1';

-- then insert
insert into TIPS_SALES_PROD.SALES.PART select * from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART 


	https://zoom.us/j/7299924465 or Conference Room