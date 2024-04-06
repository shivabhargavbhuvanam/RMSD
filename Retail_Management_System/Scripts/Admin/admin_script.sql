-- Script to be run by an administrative user

-- Dropping the store_owner user if it exists
DECLARE
  user_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(user_exists, -01918); -- Oracle error code for "user not found"
BEGIN
  EXECUTE IMMEDIATE 'DROP USER store_owner CASCADE';
  DBMS_OUTPUT.PUT_LINE('User store_owner dropped');
EXCEPTION
  WHEN user_exists THEN
    DBMS_OUTPUT.PUT_LINE('User store_owner does not exist, creating user');
END;
/

-- Creating the Store Owner user
CREATE USER store_owner IDENTIFIED BY StoreOwnerPassword00; -- Replace [password] with a secure password

ALTER USER store_owner QUOTA UNLIMITED ON DATA;

GRANT CREATE SESSION TO store_owner WITH ADMIN OPTION;
-- Granting privileges to create, alter, and drop various schema objects
GRANT CREATE TABLE, ALTER ANY TABLE, DROP ANY TABLE, 
      CREATE VIEW, DROP ANY VIEW, CREATE SESSION, DROP USER, CREATE USER,
      CREATE SEQUENCE, ALTER ANY SEQUENCE, DROP ANY SEQUENCE, CREATE ROLE, DROP ANY ROLE,
      CREATE PROCEDURE, ALTER ANY PROCEDURE, DROP ANY PROCEDURE TO store_owner;
