-- ---------------------
-- Important Notes
-- ---------------------
/*
1. No limit of db, db object in SF
2. default table is permanent table (temp, transient, external are other table types)
3. Non-permanent & transitory data can be stored in temporary & transient tables (short term data storage)
4. temporary & transient tables also called session specific data sets.
5. Temporary tables scope within the session in which they were created.
	(so where the data is stored during the session)
	- they don't support cloning
	- not accessible via other sessions
	- not recoverable (no fail safe) when session ends.
	- SF also support temporary stages (other objects too)
	- tmp data is part of storage cost and charges apply
	- tmp table data can live more than 24hrs if session is alive and it cost storage charges. 
	- tmp table and permanent/transient table can have same name
	- tmp table gets precedence over permanent & transient table
	- this behaviour is given due to time travel (duplicate table name)
	- tmp tables can not be converted to any other table once created
	- retention period (time travel) is for 24 hours or the remainder of the session, whichever is shorter.

6. Transient Table
	- There is a field in table (view) called is_transient
	- Persist until explicitly dropped
	- available to all users with privileges 
	- same as permanent table except fail safe
	- contribute to the overall storage & no fail safe cost
	- transient database and schemas are also possible 
	- schemas created under transient db and/or schema are by default transient.
	- once created, can not be converted to other table type.
	- it support clone


7. Compare
   
   Type              Presistent          Cloning           TimeTravel       FailSafe(DR)
   Permanent(Std)    Until Dropped       Yes               0 or 1           7 
   Permanent(Ent+)   Until Dropped       Yes               0 or 90          7 
   Transient         Until Dropped       Yes               0 or 1           0 
   Temporary         Session Level       Yes               0 or 1           0  

8. timetravel can be specified for the table during creation or later via alter 
9. The Fail-safe period is not configurable for any table type.
10. Transient and temporary tables have no Fail-safe period
11. External Table (ET)
	- s3, azure, google cloud storage
	- External tables store file-level metadata (file path, a version identifier, and partitioning information)
	- External tables support external (i.e. S3, Azure, or GCS) stages only; internal (i.e. Snowflake) stages are not supported.
	- Schema on read
	- No DML operation is allowed
	- External table can be used to perform join operation 
	- Views can be created onn external table
	- it is bit slower than the native SF tables 
	- materialized views on external table improves performance (Enterprise+ editionn)
	- Every ET has a column named VALUE of type VARIANT. Additional columns might be specified. All of the columns are treated as virtual columns.
		* value (a varient type) - represent single row in external file 
		* METADATA$FILENAME - a metadata column
	- METADATA$FILENAME is a pseudocolumn, identifies stage data file and its path
	- virtual columns - it can be created using value and psedocolumn
	- No referential integrity constants on external tables are enforced by Snowflake
	- The default VALUE and METADATA$FILENAME columns cannot be dropped.
	- Not supported ****
		* Clustering Key
		* Cloning
		* Data Sharing
		* Data in XML format
		* Time travel 
	- Recommendation for external table
		* partition the table
		* 

12. Create External Table need following access
	- Database - usage
	- schema - usage/create stage/create external table
	- stage - usage
*/

-- Sample code to create a temp table and insert data .. all worked well
use database TIPS_SALES_PROD;
use schema public;
create temporary table t1 (f1 numeric);
desc table t1;
insert into  t1  select p_size from part_expoert limit 100;
select * from t1;
drop table t1; -- this also works

-- if you run a show table, it shows the temporary tables too (refer image)

-- if you try to run following command on temporary table, you will get error
list @%t1 
SQL compilation error: Stage 'TIPS_SALES_PROD.PUBLIC."%T1"' does not exist or not authorized.



drop table t2
create transient table t2 (parts_name varchar(1000)); --Table T2 successfully created.
insert into  t2  select p_name from PART_EXPORT limit 1000; -- record inserted
select * from t2 limit 100;
show tables;
list @%t2; --this works


-- duplicate table name (refer images)
select * from PART_EXPORT limit 10; --this is a permanent table
create temporary table PART_EXPORT(parts_key number(38,0), parts_name varchar(55)); -- this works
create transient table PART_EXPORT(parts_key number(38,0), parts_name varchar(55)); -- this does not
drop table PART_EXPORT; -- this will drop the tmp table
show tables;

-- how to grant access to a database
GRANT USAGE, CREATE SCHEMA ON DATABASE "TIPS_DATABASE" TO ROLE "USERADMIN";

-- ---------------------
-- External Table Examples
-- ---------------------
-- additional key param is required 
create or replace stage mystage url='s3://mybucket/files/'; -- aws
create or replace stage mystage url='gcs://mybucket/files'; -- gcp
create or replace stage mystage url='azure://myaccount.blob.core.windows.net/mycontainer/files'; -- azure
	-- blob.core.windows.net endpoint for all supported types of Azure blob storage accounts, including Data Lake Storage Gen2.

-- create external table with stage reference
-- (Tip - create an internal stage reference and try to play with external table what happens)


-- desc external table
desc external table emp;

-- show external table
show external tables like 'line%' in tpch.public;

-- manually refresh external table
alter external table exttable_json refresh;

-- Similar to the first example, but manually refresh only a path of the metadata for an external table:
create or replace stage mystage
  url='<cloud_platform>://twitter_feed/logs/'
  .. ;

-- Create the external table
-- 'daily' path includes paths in </YYYY/MM/DD/> format
create or replace external table daily_tweets
  with location = @twitter_feed/daily/;

-- Refresh the metadata for a single day of data files by date
alter external table exttable_part refresh '2018/08/05/';

-- Add an explicit list of files to the external table metadata:
alter external table exttable1 add files ('path1/sales4.json.gz', 'path1/sales5.json.gz');

--Remove an explicit list of files from the external table metadata:
alter external table exttable1 remove files ('path1/sales4.json.gz', 'path1/sales5.json.gz');

-- drop external table
drop external table t2;

-- ---------------------
/*
Important Links
1. https://docs.snowflake.com/en/user-guide/databases.html
2. https://docs.snowflake.com/en/user-guide/tables-temp-transient.html#comparison-of-table-types
3. https://docs.snowflake.com/en/user-guide/tables-external.html
4. https://docs.snowflake.com/en/user-guide/tables-external-intro.html
5. https://docs.snowflake.com/en/sql-reference/sql/desc-external-table.html
6. https://docs.snowflake.com/en/sql-reference/sql/drop-external-table.html
*/
-- ---------------------


/*
https://s3.amazonaws.com/snowflake-docs/tutorials/json/server/2.6/2016/07/15/15/json_tutorial.json
{
  "device_type": "server",
  "events": [
    {
      "f": 83,
      "rv": "15219.64,783.63,48674.48,84679.52,27499.78,2178.83,0.42,74900.19",
      "t": 1437560931139,
      "v": {
        "ACHZ": 42869,
        "ACV": 709489,
        "DCA": 232,
        "DCV": 62287,
        "ENJR": 2599,
        "ERRS": 205,
        "MXEC": 487,
        "TMPI": 9
      },
      "vd": 54,
      "z": 1437644222811
    },
    {
      "f": 1000083,
      "rv": "8070.52,54470.71,85331.27,9.10,70825.85,65191.82,46564.53,29422.22",
      "t": 1437036965027,
      "v": {
        "ACHZ": 6953,
        "ACV": 346795,
        "DCA": 250,
        "DCV": 46066,
        "ENJR": 9033,
        "ERRS": 615,
        "MXEC": 0,
        "TMPI": 112
      },
      "vd": 626,
      "z": 1437660796958
    }
  ],
  "version": 2.6
}
*/