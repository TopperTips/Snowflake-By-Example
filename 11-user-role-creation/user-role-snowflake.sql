

--create a user (Blr@4950$)
CREATE USER tips_jr_analyst 
PASSWORD = '**********' 
COMMENT = 'Tips Junior Analyst to run queries' 
MUST_CHANGE_PASSWORD = TRUE;

-- with advance parameters
CREATE USER tips_jr_analyst 
PASSWORD = '**********' 
COMMENT = 'Tips Junior Analyst to run queries' 
LOGIN_NAME = 'TipsJrAnalyst' 
DISPLAY_NAME = 'Junior Analyst' 
FIRST_NAME = 'Junior' 
LAST_NAME = 'Analyst' 
EMAIL = 'tips.analyst@toppertips.com' 
MUST_CHANGE_PASSWORD = TRUE;

-- With advance params & default warehouse details
-- also granting role 
CREATE USER tips_jr_analyst 
PASSWORD = '**********' 
COMMENT = 'Tips Junior Analyst to run queries' 
LOGIN_NAME = 'TipsJrAnalyst' 
DISPLAY_NAME = 'Junior Analyst' 
FIRST_NAME = 'Junior' 
LAST_NAME = 'Analyst' 
EMAIL = 'tips.analyst@toppertips.com' 
DEFAULT_ROLE = "USERADMIN" 
DEFAULT_WAREHOUSE = 'COMPUTE_WH' 
DEFAULT_NAMESPACE = 'TIPS_DB' 
MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE "USERADMIN" TO USER tips_jr_analyst;

-- for user to see the warehouse, it has to be assigend to that role
GRANT USAGE, OPERATE, MONITOR ON WAREHOUSE "COMPUTE_WH" 
TO ROLE "USERADMIN";

-- grant the database usage
GRANT USAGE, CREATE SCHEMA, MODIFY, MONITOR ON DATABASE "TIPS_SALES_PROD" 
TO ROLE "USERADMIN";