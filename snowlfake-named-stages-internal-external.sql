-- http://toppertips.com
-- This SQL scripts is primarily for all the stage related SQL Queries.

/*

	Reference link 
	1. https://docs.snowflake.com/en/sql-reference/sql/create-stage.html
	2. https://docs.snowflake.com/en/user-guide/data-load-local-file-system-create-stage.html
*/
 
-- How to show all the stages?
show stages;

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