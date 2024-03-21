SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK ON

-- Procedure to drop table if it exists
DECLARE
  table_not_found EXCEPTION;
  insufficient_privilege EXCEPTION;
  PRAGMA EXCEPTION_INIT(table_not_found, -00955);
  PRAGMA EXCEPTION_INIT(insufficient_privilege, -01031);
BEGIN
-- Fetch the required tables and then loop over them and delete them.
  FOR t IN (SELECT table_name FROM user_tables WHERE table_name IN ('ADDRESS','CUSTOMER','PRODUCT','ORDERS','ITEM_ORDERS','EMPLOYEE','PURCHASES','VENDOR') ) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('Dropped table ' || t.table_name);
  END LOOP;
EXCEPTION
  WHEN table_not_found THEN 
    raise_application_error(-2000, 'Exit');
  WHEN insufficient_privilege THEN
    DBMS_OUTPUT.PUT_LINE('Insufficient privileges to drop table ');
END;
/
