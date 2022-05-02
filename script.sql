-- have variable substitution ON
!SET VARIABLE_SUBSTITUTION=true;

-- cleanup
USE ROLE ACCOUNTADMIN;
DROP DATABASE IF EXISTS &{tenant}_DB_&{env} CASCADE;
DROP WAREHOUSE IF EXISTS &{tenant}_ELT_&{env};
DROP WAREHOUSE IF EXISTS &{tenant}_APP_&{env};

DROP ROLE IF EXISTS &{tenant}_SYSADMIN_&{env};
DROP ROLE IF EXISTS &{tenant}_ELT_&{env};
DROP ROLE IF EXISTS &{tenant}_APP_&{env};
DROP ROLE IF EXISTS &{tenant}_RW_&{env};
DROP ROLE IF EXISTS &{tenant}_RO_&{env};

-- create roles
USE ROLE SECURITYADMIN;
CREATE OR REPLACE ROLE &{tenant}_SYSADMIN_&{env};
CREATE OR REPLACE ROLE &{tenant}_ELT_&{env};
CREATE OR REPLACE ROLE &{tenant}_APP_&{env};
CREATE OR REPLACE ROLE &{tenant}_RW_&{env};
CREATE OR REPLACE ROLE &{tenant}_RO_&{env};
 
-- create the hierarchy of roles
GRANT ROLE &{tenant}_RO_&{env} TO ROLE &{tenant}_RW_&{env};
GRANT ROLE &{tenant}_RW_&{env} TO ROLE &{tenant}_ELT_&{env};
GRANT ROLE &{tenant}_RO_&{env} TO ROLE &{tenant}_APP_&{env};
GRANT ROLE &{tenant}_ELT_&{env} TO ROLE &{tenant}_SYSADMIN_&{env};
GRANT ROLE &{tenant}_APP_&{env} TO ROLE &{tenant}_SYSADMIN_&{env};
GRANT ROLE &{tenant}_SYSADMIN_&{env} TO ROLE SYSADMIN;
 
USE ROLE ACCOUNTADMIN;
GRANT CREATE DATABASE ON ACCOUNT TO ROLE &{tenant}_SYSADMIN_&{env};
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE &{tenant}_SYSADMIN_&{env};
 
-- create databases and objects, and grant access rights
USE ROLE &{tenant}_SYSADMIN_&{env};
CREATE DATABASE &{tenant}_DB_&{env};
GRANT USAGE ON DATABASE &{tenant}_DB_&{env} TO ROLE &{tenant}_RW_&{env};
GRANT USAGE ON DATABASE &{tenant}_DB_&{env} TO ROLE &{tenant}_RO_&{env};
 
CREATE SCHEMA &{tenant}_DB_&{env}.&{tenant}_SCH_&{env};
GRANT USAGE ON SCHEMA &{tenant}_DB.&{tenant}_SCH_&{env} TO ROLE &{tenant}_RO_&{env};
GRANT USAGE ON SCHEMA &{tenant}_DB_&{env}.&{tenant}_SCH_&{env} TO ROLE &{tenant}_RW_&{env};
 
GRANT USAGE ON SCHEMA &{tenant}_DB_&{env}.PUBLIC TO ROLE &{tenant}_RO_&{env};
GRANT USAGE ON SCHEMA &{tenant}_DB_&{env}.PUBLIC TO ROLE &{tenant}_RW_&{env};
 
-- create warehouses, and grant access rights
USE ROLE &{tenant}_SYSADMIN_&{env};
CREATE WAREHOUSE &{tenant}_ELT_&{env} WAREHOUSE_SIZE = XSMALL;
GRANT OPERATE, USAGE ON WAREHOUSE &{tenant}_ELT_&{env} TO ROLE &{tenant}_ELT_&{env};
 
CREATE WAREHOUSE &{tenant}_APP_&{env} WAREHOUSE_SIZE = SMALL;
GRANT OPERATE, USAGE ON WAREHOUSE &{tenant}_APP_&{env} TO ROLE &{tenant}_APP_&{env};
 
-- grant rights on future tables
GRANT SELECT ON FUTURE TABLES
  IN SCHEMA &{tenant}_DB_&{env}.&{tenant}_SCH_&{env} TO ROLE &{tenant}_RO_&{env};
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES
  IN SCHEMA &{tenant}_DB_&{env}.&{tenant}_SCH_&{env} TO ROLE &{tenant}_RW_&{env};

-- revoke rights of the tenant SYSADMIN
USE ROLE ACCOUNTADMIN;
REVOKE CREATE DATABASE ON ACCOUNT FROM ROLE &{tenant}_SYSADMIN_&{env};
REVOKE CREATE WAREHOUSE ON ACCOUNT FROM ROLE &{tenant}_SYSADMIN_&{env};
