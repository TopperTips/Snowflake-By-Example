/*
This page is all about account usage

Reference Material
1. https://docs.snowflake.com/en/sql-reference/account-usage.html
2. https://docs.snowflake.com/en/sql-reference/account-usage.html#differences-between-account-usage-and-information-schema
*/

/*
Important note
- SNOWFLAKE is a system-defined, read-only shared database, provided by Snowflake
- The database is automatically imported into each account from a share named ACCOUNT_USAGE
- The SNOWFLAKE database is an example of Snowflake utilizing Secure Data Sharing to provide object metadata and other usage metrics for your account.
- The SNOWFLAKE database contains three schemas (also read-only). Each schema contains a set of views (refer images)

- ACCOUNT_USAGE: Views that display object metadata and usage metrics for your account.
- Diff in ACCOUNT_USAGE vs INFORMATION_SCHEMA
	- Records for dropped objects included in each view.
	- Longer retention time for historical usage data.
    - Data latency.
- By default, only account administrators (users with the ACCOUNTADMIN role) can access the SNOWFLAKE database and schemas within the database, or perform queries on the views
*/

-- Enabling Account Usage for Other Roles

USE ROLE ACCOUNTADMIN;
GRANT IMPORTED PRIVILEGES ON DATABASE snowflake TO ROLE SYSADMIN;
GRANT IMPORTED PRIVILEGES ON DATABASE snowflake TO ROLE customrole1;

USE ROLE customrole1;
SELECT * FROM snowflake.account_usage.databases;


-- Sample Queries

-- Average number of seconds between failed login attempts by user (month-to-date):
-- refer image for result and cost of the query
USE ROLE ACCOUNTADMIN;
select user_name,
       count(*) as failed_logins,
       avg(seconds_between_login_attempts) as average_seconds_between_login_attempts
from (
      select user_name,
             timediff(seconds, event_timestamp, lead(event_timestamp)
                 over(partition by user_name order by event_timestamp)) as seconds_between_login_attempts
      from "SNOWFLAKE"."ACCOUNT_USAGE"."LOGIN_HISTORY"
      where event_timestamp > date_trunc(month, current_date)
      and is_success = 'NO'
     )
group by 1
order by 3;

--Failed logins by user (month-to-date):
-- refer image for result
select user_name,
       sum(iff(is_success = 'NO', 1, 0)) as failed_logins,
       count(*) as logins,
       sum(iff(is_success = 'NO', 1, 0)) / nullif(count(*), 0) as login_failure_rate
from "SNOWFLAKE"."ACCOUNT_USAGE"."LOGIN_HISTORY"
where event_timestamp > date_trunc(month, current_date)
group by 1
order by 4 desc;


-- Failed logins by user and connecting client (month-to-date):
select reported_client_type,
       user_name,
       sum(iff(is_success = 'NO', 1, 0)) as failed_logins,
       count(*) as logins,
       sum(iff(is_success = 'NO', 1, 0)) / nullif(count(*), 0) as login_failure_rate
from "SNOWFLAKE"."ACCOUNT_USAGE"."LOGIN_HISTORY"
where event_timestamp > date_trunc(month, current_date)
group by 1,2
order by 5 desc;


-- Examples: Warehouse Credit Usage
-- Credits used by each warehouse in your account (month-to-date):
-- refer image for result
select warehouse_name,
       sum(credits_used) as total_credits_used
from "SNOWFLAKE"."ACCOUNT_USAGE"."WAREHOUSE_METERING_HISTORY"
where start_time >= date_trunc(month, current_date)
group by 1
order by 2 desc;



-- Credits used over time by each warehouse in your account (month-to-date):
-- refer image for result

select start_time::date as usage_date,
       warehouse_name,
       sum(credits_used) as total_credits_used
from "SNOWFLAKE"."ACCOUNT_USAGE"."WAREHOUSE_METERING_HISTORY"
where start_time >= date_trunc(month, current_date)
group by 1,2
order by 2,1;



-- ----------------------------
-- Examples: Data Storage Usage
-------------------------------

-- Billable terabytes stored in your account over time:
select date_trunc(month, usage_date) as usage_month
  , avg(storage_bytes + stage_bytes + failsafe_bytes) / power(1024, 4) as billable_tb
from "SNOWFLAKE"."ACCOUNT_USAGE"."STORAGE_USAGE"
group by 1
order by 1;



-------------------------------
-- Examples: User Query Totals and Execution Times
-------------------------------
-- Total jobs executed in your account (month-to-date):

select count(*) as number_of_jobs
from query_history
where start_time >= date_trunc(month, current_date);

-- Total jobs executed by each warehouse in your account (month-to-date):

select warehouse_name,
count(*) as number_of_jobs
from query_history
where start_time >= date_trunc(month, current_date)
group by 1
order by 2 desc;

--Average query execution time by user (month-to-date):

select user_name,
avg(execution_time) as average_execution_time
from query_history
where start_time >= date_trunc(month, current_date)
group by 1
order by 2 desc;

--Average query execution time by query type and warehouse size (month-to-date):

select query_type,
warehouse_size,
avg(execution_time) as average_execution_time
from query_history
where start_time >= date_trunc(month, current_date)
group by 1,2
order by 3 desc;

