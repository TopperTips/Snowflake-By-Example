
#Sample JSON Data
/*
[{"time":"6:38:51.000 PM","customer":"Talya McCambrois","action":"power off","device":"Footbot Air Quality Monitor"},
{"time":"8:13:16.000 PM","customer":"Willi Jenkerson","action":"power off","device":"GreenIQ Controller"},
{"time":"2:21:46.000 AM","customer":"Kippy Roux","action":"power off","device":"Amazon Echo"}]
*/
CREATE DATABASE "TIPS_DATABASE"

CREATE FILE FORMAT "TIPS_DATABASE"."LAB".IOT_JSON 
TYPE = 'JSON' 
COMPRESSION = 'AUTO' 
ENABLE_OCTAL = FALSE 
ALLOW_DUPLICATE = TRUE 
STRIP_OUTER_ARRAY = FALSE 
STRIP_NULL_VALUES = TRUE 
IGNORE_UTF8_ERRORS = FALSE 
COMMENT = 'JSON File Format';


-- Step 4: Creating an internal stage to load data
CREATE STAGE "TIPS_DATABASE"."LAB".IOT_LAB_STAGE 
COMMENT = 'This is iot data loading stage';



-- Step 4: Creating a table 
CREATE TABLE "TIPS_DATABASE"."LAB"."DEVICE_DATA" (
	"EVENT_TIME" TIMESTAMP NOT NULL, 
	"CUSTOMER_NAME" VARCHAR (100) NOT NULL, 
	"DEVICE_ACTION" VARCHAR (50) NOT NULL, 
	"DEVICE_NAME" VARCHAR (200) NOT NULL) 
COMMENT = 'This is customer iot device data';


PUT file://<file_path>/1.json @DEVICE_DATA/ui1589027218487

COPY INTO "TIPS_DATABASE"."LAB"."DEVICE_DATA" 
	FROM @/ui1589027218487 
	FILE_FORMAT = '"TIPS_DATABASE"."LAB"."IOT_JSON"' 
	ON_ERROR = 'CONTINUE' 
	PURGE = TRUE;

#since file has issue.. it threw following error
/*
Unable to copy files into table.
SQL compilation error: JSON/XML/AVRO file format can produce 
one and only one column of type variant or object or array. 
Use CSV file format if you want to load more than one column.
*/


CREATE TABLE "TIPS_DATABASE"."LAB"."DEVICE_DATA_VARIANT" ("DEVICE_EVENT" VARIANT NOT NULL) COMMENT = 'This is single column data';



-- Data loaded into single row
-- approach 2 to have in mutlipel rows
CREATE TABLE "TIPS_DATABASE"."LAB"."DEVICE_DATA_VARIANT_2" ("DEVICE_EVENT" VARIANT NOT NULL) COMMENT = 'Trying to load on individual rows';

CREATE FILE FORMAT "TIPS_DATABASE"."LAB".Device_Event_Format TYPE = 'JSON' COMPRESSION = 'AUTO' ENABLE_OCTAL = FALSE ALLOW_DUPLICATE = TRUE STRIP_OUTER_ARRAY = TRUE STRIP_NULL_VALUES = TRUE IGNORE_UTF8_ERRORS = TRUE COMMENT = 'Each element as single row';

PUT file://<file_path>/1.json @DEVICE_DATA_VARIANT_2/ui1589027881962

COPY INTO "TIPS_DATABASE"."LAB"."DEVICE_DATA_VARIANT_2" FROM @/ui1589027881962 FILE_FORMAT = '"TIPS_DATABASE"."LAB"."DEVICE_EVENT_FORMAT"' ON_ERROR = 'CONTINUE' PURGE = TRUE;


-- table to load ORC file via structured schema
CREATE TABLE "TIPS_DATABASE"."LAB"."ORC_DEVICE_DATA" ("EVENT_TIME" TIMESTAMP NOT NULL, "CUSTOMER_NAME" VARCHAR (100) NOT NULL, "EVENT_ACTION" VARCHAR (50) NOT NULL, "DEVICE_NAME" VARCHAR (200) NOT NULL) COMMENT = 'Storing Data from ORC File';
-- create file format to load data to table via put command
CREATE FILE FORMAT "TIPS_DATABASE"."LAB".ORC_DATA_FORMAT TYPE = 'ORC' COMMENT = 'This is ORC data format file';

-- data loading command via internal unmammed stage
PUT file://<file_path>/part-00000-921b6fdc-41bb-4b06-b5d8-a8b760cb1558-c000.snappy.orc @ORC_DEVICE_DATA/ui1589034165777

COPY INTO "TIPS_DATABASE"."LAB"."ORC_DEVICE_DATA" FROM @/ui1589034165777 FILE_FORMAT = '"TIPS_DATABASE"."LAB"."DEVICE_EVENT_FORMAT"' ON_ERROR = 'ABORT_STATEMENT' PURGE = TRUE;

-- looks it also gave an error like other data set
Unable to copy files into table.
SQL compilation error: JSON/XML/AVRO file format can produce one 
and only one column of type variant or object or array. 
Use CSV file format if you want to load more than one column.

-- Now if you have lot of large data set then it will be an expensive operation


CREATE TABLE "TIPS_DATABASE"."LAB"."ORC_DEVICE_DATA_VARIANT" ("DEVICE_DATA" VARIANT NOT NULL) COMMENT = 'This table will have only one column';


PUT file://<file_path>/part-00000-921b6fdc-41bb-4b06-b5d8-a8b760cb1558-c000.snappy.orc @ORC_DEVICE_DATA_VARIANT/ui1589034420521

COPY INTO "TIPS_DATABASE"."LAB"."ORC_DEVICE_DATA_VARIANT" FROM @/ui1589034420521 FILE_FORMAT = '"TIPS_DATABASE"."LAB"."ORC_DATA_FORMAT"' ON_ERROR = 'CONTINUE' PURGE = TRUE;


-- Now parquet type
CREATE FILE FORMAT "TIPS_DATABASE"."LAB".PARQUET_DATA_FORMAT TYPE = 'PARQUET' COMPRESSION = 'SNAPPY' BINARY_AS_TEXT = TRUE COMMENT = 'File Format for Parquet Data';


-- load command
PUT file://<file_path>/part-00000-d5a70322-eb9d-4e02-a85f-e678c1029748-c000.snappy.parquet 
@ORC_DEVICE_DATA/ui1589034857768

COPY INTO "TIPS_DATABASE"."LAB"."ORC_DEVICE_DATA" 
FROM @/ui1589034857768 
FILE_FORMAT = '"TIPS_DATABASE"."LAB"."PARQUET_DATA_FORMAT"' 
ON_ERROR = 'CONTINUE' 
PURGE = TRUE;

it also ended in errorUnable to copy files into table.
SQL compilation error: JSON/XML/AVRO file format can produce one and only one column of type variant or object or array. Use CSV file format if you want to load more than one column.


-- Now defineing a new table
CREATE TABLE "TIPS_DATABASE"."LAB"."PARQUET_DEVIDE_DATA_VARIANT" ("DEVICE_EVENT" VARIANT) COMMENT = 'The single column data loaded via Variant';


-- different options
PUT file://<file_path>/part-00000-d5a70322-eb9d-4e02-a85f-e678c1029748-c000.snappy.parquet @PARQUET_DEVIDE_DATA_VARIANT/ui1589035032039

--Do not load any data in the file
COPY INTO "TIPS_DATABASE"."LAB"."PARQUET_DEVIDE_DATA_VARIANT" FROM @/ui1589035032039 FILE_FORMAT = '"TIPS_DATABASE"."LAB"."PARQUET_DATA_FORMAT"' ON_ERROR = 'SKIP_FILE' PURGE = TRUE;
--Stop loading, rollback and return the error
COPY INTO "TIPS_DATABASE"."LAB"."PARQUET_DEVIDE_DATA_VARIANT" FROM @/ui1589035032039 FILE_FORMAT = '"TIPS_DATABASE"."LAB"."PARQUET_DATA_FORMAT"' ON_ERROR = 'ABORT_STATEMENT' PURGE = TRUE;
--Do not load any data in the file if the error count exceeds:
COPY INTO "TIPS_DATABASE"."LAB"."PARQUET_DEVIDE_DATA_VARIANT" FROM @/ui1589035032039 FILE_FORMAT = '"TIPS_DATABASE"."LAB"."PARQUET_DATA_FORMAT"' ON_ERROR = 'SKIP_FILE_100' PURGE = TRUE;
--Continue loading valid data from the file
COPY INTO "TIPS_DATABASE"."LAB"."PARQUET_DEVIDE_DATA_VARIANT" FROM @/ui1589035032039 FILE_FORMAT = '"TIPS_DATABASE"."LAB"."PARQUET_DATA_FORMAT"' ON_ERROR = 'CONTINUE' PURGE = TRUE;



-- Now trying to understand the object type
CREATE TABLE "TIPS_DATABASE"."LAB"."PARQUET_DEVIDE_DATA_OBJECT" ("EVENT_RECORD" OBJECT NOT NULL) COMMENT = 'This table has one field with object as field type';

-- loading data via put and copy command
PUT file://<file_path>/part-00000-d5a70322-eb9d-4e02-a85f-e678c1029748-c000.snappy.parquet @PARQUET_DEVIDE_DATA_OBJECT/ui1589035396167

COPY INTO "TIPS_DATABASE"."LAB"."PARQUET_DEVIDE_DATA_OBJECT" FROM @/ui1589035396167 FILE_FORMAT = '"TIPS_DATABASE"."LAB"."PARQUET_DATA_FORMAT"' ON_ERROR = 'CONTINUE' PURGE = TRUE;

-- ended up with error -- not sure why
Unable to copy files into table.
SQL execution internal error: Processing aborted due to error 300010:3163851172; incident 9323353.

-- Now the final one is to use the array
CREATE TABLE "TIPS_DATABASE"."LAB"."PARQUET_DEVICE_DATA_ARRAY" ("DEVICE_EVENT" ARRAY NOT NULL) COMMENT = 'This is an experiment with Parquet with array';
PUT file://<file_path>/part-00000-d5a70322-eb9d-4e02-a85f-e678c1029748-c000.snappy.parquet @PARQUET_DEVICE_DATA_ARRAY/ui1589035563444

COPY INTO "TIPS_DATABASE"."LAB"."PARQUET_DEVICE_DATA_ARRAY" FROM @/ui1589035563444 FILE_FORMAT = '"TIPS_DATABASE"."LAB"."PARQUET_DATA_FORMAT"' ON_ERROR = 'CONTINUE' PURGE = TRUE;

-- end up with error -- could be due to the role issue as format is created by different role
Unable to copy files into table.
SQL execution internal error: Processing aborted due to error 300010:3163851172; incident 5140068.

-- Now following is given..lets see what happens
GRANT UPDATE, INSERT, DELETE, REBUILD, REFERENCES, SELECT, TRUNCATE 
ON TABLE "TIPS_DATABASE"."LAB"."PARQUET_DEVICE_DATA_ARRAY" 
TO ROLE "SYSADMIN" WITH GRANT OPTION;


-- Now role is changed
PUT file://<file_path>/tips.snappy.parquet @PARQUET_DEVICE_DATA_ARRAY/ui1589035944814

COPY INTO "TIPS_DATABASE"."LAB"."PARQUET_DEVICE_DATA_ARRAY" FROM @/ui1589035944814 FILE_FORMAT = '"TIPS_DATABASE"."LAB"."PARQUET_DATA_FORMAT"' ON_ERROR = 'CONTINUE' PURGE = TRUE;


-- got the error like this
There was an error while trying to stage "tips.snappy.parquet".
Reason: SQL access control error: Insufficient privileges to operate on table stage 'PARQUET_DEVICE_DATA_ARRAY'

-- looks the internal stage has issues ???? looks a big issue -- looks the int stage has access issue

-- so createa a table again with sysadmin
CREATE TABLE "TIPS_DATABASE"."LAB"."PARQUET_TYPE_ARRAY" ("DEVICE_EVENT" ARRAY NOT NULL) COMMENT = 'Parquet data loaded in array data type';
-- step-2
PUT file://<file_path>/tips.snappy.parquet @PARQUET_TYPE_ARRAY/ui1589036262859
COPY INTO "TIPS_DATABASE"."LAB"."PARQUET_TYPE_ARRAY" FROM @/ui1589036262859 FILE_FORMAT = '"TIPS_DATABASE"."LAB"."PARQUET_DATA_FORMAT"' ON_ERROR = 'CONTINUE' PURGE = TRUE;

-- step-3 looks error again
Unable to copy files into table.
SQL execution internal error: Processing aborted due to error 300010:3163851172; incident 5508373.

-- @TOD - understant the object and array data type and why it is not not working with parquet.

