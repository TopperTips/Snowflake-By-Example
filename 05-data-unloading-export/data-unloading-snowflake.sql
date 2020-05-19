-- Data Unloading & Export Function
/*
We all know that Snowflake is cloud native warehouse system, data unloading and export function cost.
Hence it is very important to understand the data unloading practices and follow the guidelines.
There are various ways data can be exported effectively (like cloud resion, buckets, local box etc) and following topics will help us to explore them in detail.

Key concepts related to data unloading, as well as best practices.
	Overview of Data Unloading
	Summary of Data Unloading Features
	Data Unloading Considerations

Overview of supported data file formats for unloading data.
	Preparing to Unload Data

Detailed instructions for unloading data in bulk using the COPY command.
	Unloading into a Snowflake Storage
	Unloading into Amazon S3
	Unloading into Google Cloud Storage
	Unloading into Microsoft Azure
*/

/*

-- Important links
1. https://docs.snowflake.com/en/user-guide-data-unload.html
2. https://docs.snowflake.com/en/user-guide/data-unload-overview.html
3. https://docs.snowflake.com/en/user-guide/intro-summary-unloading.html
4. https://docs.snowflake.com/en/user-guide/data-unload-considerations.html
5. https://docs.snowflake.com/en/user-guide/data-unload-snowflake.html (good one)

-- Related Links
1. Data loading guide - https://docs.snowflake.com/en/user-guide-data-load.html
2. Loading Unloading DDLs - https://docs.snowflake.com/en/sql-reference/ddl-stage.html
3. DML commands - https://docs.snowflake.com/en/sql-reference/sql-dml.html

*/

/*
Important Faqs which will be clarified later
1. Can data be loaded in different file formats like json/parque etc? or it is always csv?
2. Data can only be unloaded to stages? External/Internal?
3. What are the file size or naming patter or overwirte strategy to the stage location?
4. How does it chunk the file - what is the strategy?
4. How to download data from many tables using query? Is the COPY INTO only option?
5. Unloaded/exported data to internal or external stages are cloned when clone operation is performed - to be tried
6. 
*/

/*
Points to remember
1. Snowflake supports bulk export (i.e. unload) of data from a database table into flat, delimited text files
2. Use 'COPY INTO <location>' command (similar to load) the data from the Snowflake database table into one or more files in a Snowflake or external stage.
	(Tip: it is alwasy stages?)
3. Use the get command to download the file.
	(Tip: so it is 2 stage process.. like a actual warehouse.. get the item at stage area and then get it in your truck)
4. Select query can also be used instead of 'COPY INTO <location>'
	(Tip: look for code syntax)
5. Select query support full syntax including JSON style to download.
6. 'COPY INTO <location>' command provides option to specify single file or multiple (default SINGLE = FALSE)
7. Snowflake provides each file a unique name 
	(Tip: try this out to reinformce the understanding and file name patters)
8. Snowflake prefixes the generated filenames with "data_".
9. Snowflake appends a suffix that ensures each file name is unique across parallel execution threads; e.g. data_stats_0_1_0.
10. MAX_FILE_SIZE copy option to specify each file
	(Tip: mb or gb or what?)
11. Compression/Encryption is decideds if stage is external or internal.
12. Location of stages - Internal (local), AWS s3, GCP bucket, Azure file 
13. File formats - delited files (CSV/TSV), JSON, Parquet
	(Tip: not supported ORC, xml)
14. File encoding - UTF-8
15. Compression - gzip (default)/bzip2/Brotil/ZStandard
16. File Encryption - for internal stages - 128-bit (256-bit need configuration)
17. File Encryption - for external - user supplied key (possible only if it is provided)
 

Super Important Notes
1. An empty string is a string with zero length or no characters, whereas NULL values represent an absence of data
2. For CSV (delimited files)
	2.1 An empty string -  ,'',, to indicate that the string contains zero characters
	2.2 a NULL value is typically represented by two successive delimiters (e.g. ,,) 
	(Tip: get your hands on to reinforce theory and also try with TSV)
3. FIELD_OPTIONALLY_ENCLOSED_BY = 'character' | NONE - use this option to define behaviour (PREFERRED ONE****)
4. EMPTY_FIELD_AS_NULL = TRUE|FALSE option set to FALSE
5. NULL_IF = ('<string>',[,'<string>']) : When unloading data from tables: Snowflake converts SQL NULL values to the first value in the list.
	(Tip: see all the option in play .. refer images)
6. ESCAPE_UNENCLOSED_FIELD = \\N (default)
*/



-- Setting the param for ui session with 
-- worksheet to work with specific role/warehouse/db/schema
use role sysadmin;
use warehouse compute_wh; 
use database TIPS_SALES_PROD;
use schema public;

-- populate data to a table from the example table
CREATE TABLE part_export  LIKE snowflake_sample_data.tpch_sf1.part 
INSERT INTO part_export select * from snowflake_sample_data.tpch_sf1.part 

-- copying data to stage in csv format
copy into @export_stg/default_csv from part_export
-- all records loaded to stage and md5 check is also generated
-- the default_csv will be the prefix _0_0_0.csv.gz

-- Note: if you don't give a name and if stage is having data followign error will come
-- <error> Files already existing at the unload destination: @export_stg. Use overwrite option to force unloading.
-- use remove function as alterntively
REMOVE @export_stg/export_stg/default_csv_0_0_0.csv.gz





-- Creating a table
create or replace table tips_export(
id number(8) not null,
first_name varchar(255) default null,
last_name varchar(255) default null,
city varchar(255),
state varchar(255)
);


-- Populate the table with data
insert into tips_export (id,first_name,last_name,city,state)
 values
(1,'Goutam','Shetty','Salt Lake City','UT'),
(2,'Rue','Shane','Birmingham','AL'),
(3,'John','Heck','Columbus','GA'),
(3,'John','Heck','Columbus','GA'),
(3,'Pick','Me','New York','NY'),
(3,'Drop','You','Columbus','GA'),
(3,'Hell','Nick','Columbus','GA'),
(3,'Sim','Jack','Columbus','GA'),
(3,'Jim','Raw','Columbus','GA'),
(3,'Tium','Keo','New York','NY');

-- create a stage
CREATE STAGE export_stg COMMENT = 'my_simple_stage';

-- initiate a copy command and load data in json using selecd query
copy into @export_stg
from (select object_construct('id', id, 'first_name', first_name, 'last_name', last_name, 'city', city, 'state', state) from tips_export)
file_format = (type = json);


-- Data unload in parquet format
copy into @export_stg/myfile.parquet 
from (select id, first_name, last_name, city,state  from tips_export)
file_format=(type='parquet')
header = true;



-- export multiple & compression
REMOVE @export_stg/file_size_0_0_0.csv.gz
REMOVE @export_stg/file_size_0_0_1.csv.gz
copy into @export_stg/file_size from part_export
file_format = (type=csv compression='gzip')
max_file_size=102400;