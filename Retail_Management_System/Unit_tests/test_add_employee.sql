CREATE OR REPLACE PROCEDURE TEST_ADD_EMPLOYEE_RECORD IS
BEGIN
  NULL;  -- Placeholder to avoid data deletion
END TEST_ADD_EMPLOYEE_RECORD;
/

BEGIN
  TEST_ADD_EMPLOYEE_RECORD;
END;
/

DECLARE
  -- Test Case 1: Inserting a new employee with valid data
  PROCEDURE test_valid_employee AS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Positive Test Case');
    DBMS_OUTPUT.PUT_LINE('Test Case 1: Inserting a new employee with valid data');
    DBMS_OUTPUT.PUT_LINE('');

    ADD_EMPLOYEE_RECORD(
      pi_first_name => 'John',
      pi_last_name => 'Doe',
      pi_email => 'john.doe@example.com',
      pi_phone => '1234567890',
      pi_hiring_date => SYSTIMESTAMP,
      pi_role => 'Accountant',
      pi_wage => 50000,
      pi_house_number => 123,
      pi_street => 'Main Street',
      pi_city => 'Anytown',
      pi_state => 'State',
      pi_country => 'Country',
      pi_postal_code => 12345
    );

    DBMS_OUTPUT.PUT_LINE('Expected outcome: Employee record added successfully');
  END test_valid_employee;

  -- Test Case 2: Providing NULL values for mandatory fields
  PROCEDURE test_null_values AS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Negative Test Case');
    DBMS_OUTPUT.PUT_LINE('Test Case 2: Providing NULL values for mandatory fields');
    DBMS_OUTPUT.PUT_LINE('');

    ADD_EMPLOYEE_RECORD(
      pi_first_name => NULL,
      pi_last_name => NULL,
      pi_email => NULL,
      pi_phone => NULL,
      pi_hiring_date => NULL,
      pi_role => NULL,
      pi_wage => NULL,
      pi_house_number => NULL,
      pi_street => NULL,
      pi_city => NULL,
      pi_state => NULL,
      pi_country => NULL,
      pi_postal_code => NULL
    );
    -- Check if the procedure correctly handles NULL values
    DBMS_OUTPUT.PUT_LINE('Expected outcome: Error: Invalid input arguments');
  END test_null_values;

  -- Test Case 3: Providing an email address that already exists
  PROCEDURE test_existing_email AS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Negative Test Case');
    DBMS_OUTPUT.PUT_LINE('Test Case 3: Providing an email address that already exists');
    DBMS_OUTPUT.PUT_LINE('');

    ADD_EMPLOYEE_RECORD(
      pi_first_name => 'John',
      pi_last_name => 'Doe',
      pi_email => 'john.doe@example.com',
      pi_phone => '1234567890',
      pi_hiring_date => SYSTIMESTAMP,
      pi_role => 'Accountant',
      pi_wage => 50000,
      pi_house_number => 123,
      pi_street => 'Main Street',
      pi_city => 'Anytown',
      pi_state => 'State',
      pi_country => 'Country',
      pi_postal_code => 12345
    );
    -- Check if the procedure correctly handles existing email addresses
    DBMS_OUTPUT.PUT_LINE('Expected outcome: Error: Email already exists');
  END test_existing_email;
BEGIN
  -- Execute test cases
  test_valid_employee;
  test_null_values;
  test_existing_email;
END;
/
