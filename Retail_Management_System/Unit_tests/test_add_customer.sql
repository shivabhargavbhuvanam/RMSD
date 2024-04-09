CREATE OR REPLACE PROCEDURE TEST_ADD_CUSTOMER_RECORD IS

  -- Procedure to handle test results
  PROCEDURE assert(condition IN BOOLEAN, message IN VARCHAR2) IS
  BEGIN
    IF condition THEN
      DBMS_OUTPUT.PUT_LINE('Test PASSED: ' || message);
    ELSE
      DBMS_OUTPUT.PUT_LINE('Test FAILED: ' || message);
    END IF;
  END assert;

  -- Test Case 1: Inserting a new customer with valid data
  PROCEDURE test_valid_customer AS
    v_customer_count INTEGER;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Positive Test Case: Inserting a new customer with valid data');

    ADD_CUSTOMER_RECORD(
      pi_first_name => 'Alice',
      pi_last_name => 'Smith',
      pi_phone => '9876543210',
      pi_email => 'alice.smith@example.com',
      pi_house_number => 100,
      pi_street => 'Maple Street',
      pi_city => 'Somecity',
      pi_state => 'Somestate',
      pi_country => 'Somecountry',
      pi_postal_code => 12345
    );

    SELECT COUNT(*) INTO v_customer_count FROM CUSTOMER WHERE EMAIL = 'alice.smith@example.com';
    assert(v_customer_count = 1, 'Valid customer added');
  END test_valid_customer;

  -- Test Case 2: Providing NULL values for mandatory fields
  PROCEDURE test_null_values AS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Negative Test Case: Providing NULL values for mandatory fields');

    BEGIN
      ADD_CUSTOMER_RECORD(
        pi_first_name => NULL,
        pi_last_name => NULL,
        pi_phone => NULL,
        pi_email => NULL,
        pi_house_number => NULL,
        pi_street => NULL,
        pi_city => NULL,
        pi_state => NULL,
        pi_country => NULL,
        pi_postal_code => NULL
      );
      assert(FALSE, 'NULL values test failed to raise an exception');
    EXCEPTION
      WHEN OTHERS THEN
        assert(SQLCODE = -2000, 'Expected exception for NULL inputs raised');
    END;
  END test_null_values;

  -- Test Case 3: Providing an email address that already exists
  PROCEDURE test_existing_email AS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Negative Test Case: Providing an email address that already exists');

    BEGIN
      ADD_CUSTOMER_RECORD(
        pi_first_name => 'Bob',
        pi_last_name => 'Johnson',
        pi_phone => '9876543210',
        pi_email => 'alice.smith@example.com', -- Assuming this email already exists
        pi_house_number => 101,
        pi_street => 'Oak Street',
        pi_city => 'Anothercity',
        pi_state => 'Anotherstate',
        pi_country => 'Anothercountry',
        pi_postal_code => 54321
      );
      assert(FALSE, 'Duplicate email test failed to raise an exception');
    EXCEPTION
      WHEN OTHERS THEN
        assert(SQLCODE = -2000, 'Expected exception for duplicate email raised');
    END;
  END test_existing_email;

BEGIN
  -- Execute test cases
  test_valid_customer;
  test_null_values;
  test_existing_email;
END TEST_ADD_CUSTOMER_RECORD;
/

-- To run the test procedure
BEGIN
  TEST_ADD_CUSTOMER_RECORD;
END;
/
