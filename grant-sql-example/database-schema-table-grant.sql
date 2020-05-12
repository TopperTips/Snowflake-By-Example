
/*
Reference Material
1. https://docs.snowflake.com/en/sql-reference/sql/grant-privilege.html

*/
-- Giving a usage grant on a table to public role
GRANT USAGE ON DATABASE "DB_FOR_SECURITY" TO ROLE "PUBLIC" WITH GRANT OPTION;



-- How To: Grant a role access to database objects in a schema
/*
To allow a role to use database objects in a specific schema, 
the owner of the database objects (typically a system administrator (SYSADMIN role)) 
must grant privileges on the database, schema, and objects.
*/

--Grant usage on the database:
GRANT USAGE ON DATABASE <database> TO ROLE <role>;
 

--Grant usage on the schema:
GRANT USAGE ON SCHEMA <database>.<schema> TO ROLE <role>;

--Grant the ability to query an existing table:
GRANT SELECT ON TABLE <database>.<schema>.<table> TO ROLE <role>;

/*
The following table privileges are supported:
Privilege			Usage
SELECT				Execute a SELECT statement on the table.
INSERT				Execute an INSERT command on the table.
UPDATE				Execute an UPDATE command on the table.
TRUNCATE			Execute a TRUNCATE command on the table.
DELETE				Execute a DELETE command on the table.
REFERENCES			Reference the table as the unique/primary key table for a foreign key constraint.
ALL [ PRIVILEGES ]	Grant all privileges, except OWNERSHIP, on the table.
OWNERSHIP			Grant full control over a table.

*/