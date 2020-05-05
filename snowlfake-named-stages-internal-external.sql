-- http://toppertips.com
-- This SQL scripts is primarily for all the stage related SQL Queries.

/*

	Reference link 
	1. https://docs.snowflake.com/en/sql-reference/sql/create-stage.html
	2. https://docs.snowflake.com/en/user-guide/data-load-local-file-system-create-stage.html
	3. Alter Stages : https://docs.snowflake.com/en/sql-reference/sql/alter-stage.html
*/
 
-- How to show all the stages?
show stages;
list @S3_USDF_EXTERNAL_NAMED_STAGE;              --loading all files inside the bucket
list @S3_USDF_EXTERNAL_NAMED_STAGE/load;         -- loading specific directory



-- Note : it is not stage, it is stages, make sure you remember the command.



-- Create a name internal stage (a temporary loading area)
-- This stage will be created within public schema if there is no other schema. 
-- you can change the schema and databaes names

CREATE OR REPLACE STAGE "USDA_NUTRIENT_STDREF"."PUBLIC".Tips_Internal_Storage 
	COMMENT = 'An internal staging area';

-- The grant query to be documented?

-- Reference 

-- Create a named external stage (a temporary loading area) with AWS S3 (Simple Storage Services)
-- This stage will be created within public schema if there is no other schema. 
-- you can change the schema and databaes names
CREATE OR REPLACE STAGE "USDA_NUTRIENT_STDREF"."PUBLIC".S3_Tips_External_Named_Stage 
	URL = 's3://my-sample-bucket' 
	CREDENTIALS = (AWS_KEY_ID = 'myuser' AWS_SECRET_KEY = '********') 
	ENCRYPTION = (MASTER_KEY = '*********') 
	COMMENT = 'S3_Tips_External_Named_Stage';

-- Creating a temporary storage
-- Not documentation is found how it is different from normal stage and what is the purpose
-- This is to be explroed ???
CREATE OR REPLACE TEMPORARY STAGE "USDA_NUTRIENT_STDREF"."PUBLIC".S3_TEMPO_EXTERNAL_NAMED_STAGE 
	URL = 's3://my-sample-bucket' 
	CREDENTIALS = (AWS_KEY_ID = 'myuser' AWS_SECRET_KEY = '********')  
	COMMENT = 'Checking what is this temporary stage is';

-- Alter Stage (Changing Paramters)
ALTER STAGE "USDA_NUTRIENT_STDREF"."PUBLIC"."S3_USDF_EXTERNAL_NAMED_STAGE" 
	SET URL = 's3://on-demand-files' 
	COMMENT = 'S3_USDF_EXTERNAL_NAMED_STAGS';

-- Alter rename does not work, looks like it is not supported as UI also does not allow.
ALTER STAGE IF EXISTS "USDA_NUTRIENT_STDREF"."PUBLIC".S3_TEMPO_EXTERNAL_NAMED_STAGE  
RENAME "USDA_NUTRIENT_STDREF"."PUBLIC".S3_TEMPO_EXTERNAL_NAMED_STAGE_RENAMED

-- (this will end with error : SQL compilation error: syntax error line 2 at position 7 unexpected '"USDA_NUTRIENT_STDREF"'. )

-- Even unset comment does not seems to be working
-- (error : Unsupported feature 'UNSET'.)

-- Note-01: if you input incorrect AWS keys, Snowflake will throw error like this
--Unable to create stage "S3_TIPS_EXTERNAL_NAMED_STAGE".
--The provided master key has invalid length. It must be either 128 bits, 192 bits, or 256 bits long.

-- Note-02: If the bucket(s3) is publickly available, then you don't need to specify the key at all.


-- Creating External Named Stages with Azure
CREATE OR REPLACE STAGE "USDA_NUTRIENT_STDREF"."PUBLIC".Azure_Tips_External_Named_Stage 
	URL = 'azure://azurebucket' 
	CREDENTIALS = (AZURE_SAS_TOKEN = '********************') 
	ENCRYPTION = (TYPE = 'AZURE_CSE' MASTER_KEY = '****************************************') 
	COMMENT = 'Azure_Tips_External_Named_Stage';




-- How to create a stage by cloing it
-- Creating a clone works for external stage but does not work for internal stages
CREATE STAGE "USDA_NUTRIENT_STDREF"."PUBLIC".Cloned_s3_tips 
	CLONE "USDA_NUTRIENT_STDREF"."PUBLIC"."S3_TIPS_EXTERNAL_NAMED_STAGE" 
	COMMENT = 'Cloning an s3 named stage';

-- Note-01 : If you try to create a clone using internal stages, it will throw error
/*
Unable to create stage "CLONE_INTERNAL_STAGE".
Unsupported feature 'Cloning internal and temporary stages'.
*/

-- Note-02 : Grants are also not copied when you clone 

/*
-- ------------------------------------
Different kind of error may appear if you are not having sufficient privileges
so make sure you check the role using the role manu and then run the queries or operations.

Check for the ICON called "Owner" on WebUI before operating on any staged object
-- ------------------------------------

Unable to modify stage "S3_TIPS_EXTERNAL_NAMED_STAGE".
SQL access control error: Insufficient privileges to operate on stage 'S3_TIPS_EXTERNAL_NAMED_STAGE'




