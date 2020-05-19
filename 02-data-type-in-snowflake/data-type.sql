




-- Summary of data type
/*
Legend
-------
<***IMP***> : This is bit different in Snowflake over other Database system

Snowflake has its internal way of storing data, so on surface it support many style but many of them are just alias or same like int and decimal are all numbers

1. Numeric - Number (38,0) (rest all numbers are stored with this data type no matter what definition you give)
			= decimal,float,real, int, big int, etc...

2. String/Binary Data Type
		= string/text/varchar
		= char -> varchar(1)
		= Binary = varbinary

3. Logical Data Type = Boolean (account supported post 25 Jan 2016)
4. Date/Time = 	Date
				Time
				DateTime
				TimeStamp
				TimeStamp_LTZ (Local Time Zone)
				TimeStamp_NTZ (with no timezone)
				TimeStamp_TZ (with timezone)

5. Semi Structured -  	Variant
						Object
						Array

Note : Snowflake displays FLOAT, FLOAT4, FLOAT8, REAL, DOUBLE, and DOUBLE PRECISION as FLOAT


Key Note about Numeric Data Type
	- Numeric Data types are fixed point (int, bigint etc), floating point (float/double), constant/literal
	- Number up to 38 with optional precision
	- Precition - total number of digit allowed
	- scale - totla # of digit right to the decimal point (37)
	- data converted from higher to lower and back to higher, it will lose precision
	- Example : convert a NUMBER(38,37) to DOUBLE (has 17 prevision), and then back to NUMBER, it lose its precision
	- Precision (total number of digits) does not impact storage <***IMP***>
	- SF Micropartition determine min/max precision for given column and then store <***IMP***>
	- Example: col values 1,2,3,4,5 -> 1 byte uncompressed
	           col values 1,2,3,100000 -> 4 byte uncompressed
	- scale (number of digits following the decimal point) does have an impact on storage <***IMP***>
	- column of type NUMBER(10,5) consumes more space than NUMBER(5,0) + processing cost is higher <***IMP***>


Key Note about Floating Point Numbers
	- SF uses double-precision (64 bit) IEEE 754 floating point numbers.
	- SF Supports following special values for Float
		'NaN' -> Not a number
		'inf' -> infinity
		'-inf' -> negative infinity
		** these symbols must be single quote
	- IEEE 745 vs SF when apply condition check
		if( 'NaN' = 'NaN') .. in SF it is true but not in IEEE
		IF('NaN' > X) ........in SF it is true but not in IEEE

Constant/Literals for Numbers
	- e/E indicate exponent (At least one digit must follow the exponent marker if present.)
	- Example 1.234E2 , 1.234E+2 , 15e-03
	- +/- indicate postive or negative, default is +


Key Note about String & Binary Datatype
	- VARCHAR holds unicode characters.
	- max length is 16 MB (uncompressed) (single byte 16,777,216 and 2bypte/4byte per char - 8,388,608 to 4,194,304)
	- If a length is not specified, the default is the maximum length. <***IMP***>
	- char/character same as varchar and not defined it is 1 default.
	- for char datatype, no padding givein like standard database.

Key Note about Binary
	- Max length = 8Mb
	- No notion of unicode charater, so length is always same.
	- varbinary = binary
	- internal representation - The BINARY data type holds a sequence of 8-bit bytes.
	- HELP is stored and will display as 48454C50 (H=48 in ascii)

String Constant
	- String constants in SF must always be enclosed between delimiter characters.
	- SF supports using either single quotes or dollar signs to delimit string constants <***IMP***>
		Tip: in standard database, single quote is used for constant in select statement
	- select 'today' as today, $$t o d a y$$ as today_with_dollar 
	- select $$wow \t wow$$ as today
	- Two single quotes is not the same as the double quote character
	- $$string with a ' character$$
	- Note that the string constant cannot contain double-dollar signs. <***IMP***>

Boolean Data Type & Key Note
	- BOOLEAN can have TRUE/FALSE values.
	- BOOLEAN can also have an “unknown” value, which is represented by NULL
	- Boolean Conversionn
		* String 
		* true/t/yes/y/on/1 = True
		* false/f/no/f/off/0 = False
		*
		* Numeric
		* 0 - zero is false
		* any non zero (+/-) is true
	- String/Numeric convertionnn
		* to_string(True) -> true (lower case) -> 1 (for number)
		* to_string(False) -> false (lower case) -> 0 (for number)
	- Null is converted to NULL 

Quik Review - Ternary Logic - three-valued logic (3VL)
	- logic system with three truth values: TRUE, FALSE, and UNKNOWN
	- Snowflake, UNKNOWN is represented by NULL
	- When used in expressions (e.g. SELECT list), UNKNOWN results are returned as NULL values.	
	- When used as a predicate (e.g. WHERE clause), UNKNOWN results evaluate to FALSE.

Date/time key notes
	- single DATE data type for storing dates (with no time elements)
	- DATE supported formats for string constants (YYYY-MM-DD, DD-MON-YYYY, etc.)
	- When a date-only format is used, the associated time is assumed to be midnight on that day.
	- timestap = combined date + time
	- DATETIME is an alias for TIMESTAMP_NTZ
	- all accepted timestamps are valid inputs for dates
	-TIME data type for storing times in the form of HH:MI:SS
	- TIME supports an optional precision parameter for fractional seconds, e.g. TIME(3)
	- Time precision can range from 0 (seconds) to 9 (nanoseconds). The default precision is 9
	- All TIME values must be between 00:00:00 and 23:59:59.999999999
	- TIME internally stores “wallclock” time, and all operations on TIME values are performed without taking any time zone into consideration
*/

-- setting the timezone
alter session set timestamp_type_mapping = timestamp_ntz;
create or replace table ts_test(ts timestamp);
desc table ts_test;

create or replace table ts_test2(ts timestamp_ltz);
desc table ts_test2;

Use TIMESTAMP_LTZ with different time zones:
/*
Important links:
1.https://docs.snowflake.com/en/sql-reference/data-types.html
2. https://docs.snowflake.com/en/sql-reference/data-types-numeric.html
3. https://docs.snowflake.com/en/sql-reference/data-types-text.html
4. https://docs.snowflake.com/en/user-guide/binary-input-output.html
5. https://docs.snowflake.com/en/sql-reference/data-types-logical.html
6. https://docs.snowflake.com/en/sql-reference/ternary-logic.html
*/