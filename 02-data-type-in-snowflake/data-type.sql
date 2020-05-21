




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

calendar support
	-Snowflake uses the Gregorian Calendar for all dates and timestamps

Date and Time Constants
	- Snowflake supports using string constants to specify fixed date, time, or timestamp values
	- String constants must always be enclosed between delimiter characters
	- example
		date '2010-09-14'
		time '10:03:56'
		timestamp '2009-09-15 10:59:43'

		create table t1 (d1 date);
		insert into t1 (d1) values (date '2011-10-29');
		value format can be set as alter session set date-input-format ='yyyy-MM-dd'

Interval Constants
	-interval constants to add/subtract a period of time to/from a date, time, or timestamp
	- Example
		INTERVAL '1 YEAR' represents 1 year.
		INTERVAL '4 years, 5 months, 3 hours' represents 4 years, 5 months, and 3 hours
		INTERVAL '1 year, 1 day' first adds/subtracts a year and then a day.
		INTERVAL '1 day, 1 year' first adds/subtracts a day and then a year.
	-SQL
		select to_date ('2019-02-28') + INTERVAL '1 day, 1 year'; -- result 2020-03-01 
		select to_date ('2019-02-28') + INTERVAL '1 year, 1 day'; -- result 2020-02-29
	- INTERVAL is not a data type and can be used only with date/time

	-- More example
		select to_date('2018-04-15') + INTERVAL '1 year'; -- 2019-04-15  
		select to_time('04:15:29') + INTERVAL '3 hours, 18 minutes'; --07:33:29
		select name, hire_date from employees where hire_date > current_date - INTERVAL '2 y, 3 month';
		select to_date('2025-01-17') + INTERVAL
                               '1 y, 3 q, 4 mm, 5 w, 6 d, 7 h, 9 m, 8 s,
                                1000 ms, 445343232 us, 898498273498 ns'
                            as complex_interval2;

                            -- 2027-03-30 07:31:32.841

Simple Arithmetic for Dates
	- TIME and TIMESTAMP values do not yet support simple arithmetic.
	- select to_date('2018-04-15') + 1; -- 2018-04-16 
	-- select to_date('2018-04-15') - 4; -- 2018-04-11  

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