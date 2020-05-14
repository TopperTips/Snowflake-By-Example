/*
Important links
1.https://s3.amazonaws.com/snowflake-workshop-lab/Snowflake_free_trial_LabGuide.pdf

*/


/*
Important Notes
- For any role to function, we need at least one user assigned to it 
- SYSADMIN role by default cannot create new roles or users. role creation operation will fail
*/

create role tips_jr_dba;
grant role tips_jr_dba to user tips_dba_user02;
use role tips_jr_dba;

-- Now we have to give usage access to this new role
use role accountadmin;
grant usage on database citibike to role tips_jr_dba;
grant usage on database weather to role tips_jr_dba;