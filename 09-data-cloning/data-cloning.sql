-- data-cloning.sql


-- Important links
-- 1. https://docs.snowflake.com/en/user-guide/object-clone.html
-- 2. 



-- Cloning a database
CREATE DATABASE TIPS_DATABASE_QA 
CLONE "TIPS_DATABASE" 
COMMENT = 'This is cloned database from Tips Database';



-- Create like feature to copy table, but data is not copied
CREATE TABLE "TIPS_DATABASE_QA"."LAB".DEVICE_DATA_CREATE_LIKE 
LIKE "TIPS_DATABASE_QA"."LAB"."DEVICE_DATA" 
COMMENT = 'Create like feature is used which is similar to clone';



-- Cloning a file format
-- img exist
CREATE FILE FORMAT "TIPS_DATABASE_QA"."LAB".CLONED_DEVICE_EVENT_FORMAT 
CLONE "TIPS_DATABASE_QA"."LAB"."DEVICE_EVENT_FORMAT" 
COMMENT = 'Cloning a file formate to the same schema';


-- Create a stage via clone.
-- img exist
CREATE STAGE "TIPS_DATABASE_QA"."LAB".CLONE_JSON_STAGE 
CLONE "TIPS_DATABASE_QA"."LAB"."JSON_STAGE" 
COMMENT = 'This is stage cloning for named external stage';