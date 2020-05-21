-- ------------------------------
-- Variant/Array/Object Data Type
-- ------------------------------

Introduction Key Note
---------------------
Semi-structure data type: used to represent arbitrary data structures 
Can be used to import/operate on semi-structured data 
	JSON
	Avro
	ORC
	Parquet
	XML
Snowflake stores these types internally in an efficient compressed columnar binary representation

Variant
-------
	universal type, can store values of any other type, including OBJECT and ARRAY
	maximum size of 16 MB compressed
	A value of any data type can be implicitly cast to a VARIANT value, subject to size restrictions
	example : (var:json_path >= 56) is cast to (var:json_path >= 56::VARIANT) for compare
	VARIANT value can be missing (contain SQL NULL), which is different from a VARIANT null value
	** VARIANT columns in a relational table are stored as separate physical columns


Object
-------
	Used to represent collections of key-value pairs, 
	key is a non-empty string, and the value is a value of VARIANT type
	Snowflake does not currently support explicitly-typed objects.

Array
------
	Used to represent dense or sparse arrays of arbitrary size

Unsupported Data Type
----------------------
	LOB (Large Object) - BINARY can be used instead
	CLOB - VARCHAR can be used instead;
	ENUM
	User-defined data types


Querying Semi-structured Data
------------------------------
	Snowflake supports SQL queries that access semi-structured data
	JSON, Avro, ORC, and Parquet data (but not to xml)
	Traverse Pattern 	Insert a colon : between the VARIANT column name and any first-level element
						<column>:<level1_element>.
	Query output is enclosed in double quotes because the query output is VARIANT, not VARCHAR
	Operators : and subsequent . and [] always return VARIANT values containing strings
	There are two ways to access elements in a JSON object:
		Dot Notation
		Bracket Notation
	Regardless of which notation you use, the column name is case-insensitive but element names are case-sensitive
		src:salesperson.name
		SRC:salesperson.name
		SRC:Salesperson.Name
	Dot notation
		select src:salesperson.name from car_sales;
	Bracker notation -- Enclose element names in single quotes
		select src['salesperson']['name'] from car_sales;
	Repeating elements
		select src:vehicle[0] from car_sales;
		select src:vehicle[0].price from car_sales;
	Explicitly Casting 
		select src:salesperson.id::string from car_sales;
	FLATTEN Function to Parse Arrays
		FLATTEN is a table function that produces a lateral view of a VARIANT, OBJECT, or ARRAY
		Example:
			select
	  			value:name::string as "Customer Name",
	  			value:address::string as "Address"
	  		from
	    		car_sales
	  		, lateral flatten(input => src:customer);
/*
Important Links
1. https://docs.snowflake.com/en/sql-reference/data-types-semistructured.html
2. https://docs.snowflake.com/en/sql-reference/data-types-semistructured.html
*/