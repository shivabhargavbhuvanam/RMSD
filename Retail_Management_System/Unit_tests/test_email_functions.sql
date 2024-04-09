CREATE OR REPLACE PROCEDURE TEST_VALIDATE_EMAIL IS
  v_test_email_valid VARCHAR2(100) := 'test@example.com';
  v_test_email_invalid VARCHAR2(100) := 'testexample.com';

  PROCEDURE assert(condition IN BOOLEAN, message IN VARCHAR2) IS
  BEGIN
    IF condition THEN
      DBMS_OUTPUT.PUT_LINE('Test PASSED: ' || message);
    ELSE
      DBMS_OUTPUT.PUT_LINE('Test FAILED: ' || message);
    END IF;
  END assert;

BEGIN
  -- Test with a valid email
  assert(VALIDATE_EMAIL(v_test_email_valid) = TRUE, 'Valid email test');

  -- Test with an invalid email
  assert(VALIDATE_EMAIL(v_test_email_invalid) = FALSE, 'Invalid email test');
END TEST_VALIDATE_EMAIL;
/

-- Run the test procedure for VALIDATE_EMAIL
BEGIN
  TEST_VALIDATE_EMAIL;
END;
/


CREATE OR REPLACE PROCEDURE TEST_EMAIL_EXISTS IS
  v_test_existing_email VARCHAR2(100) := 'known_email@example.com'; -- Replace with an existing email in your test database
  v_test_non_existing_email VARCHAR2(100) := 'non_existing_email@example.com';

  PROCEDURE assert(condition IN BOOLEAN, message IN VARCHAR2) IS
  BEGIN
    IF condition THEN
      DBMS_OUTPUT.PUT_LINE('Test PASSED: ' || message);
    ELSE
      DBMS_OUTPUT.PUT_LINE('Test FAILED: ' || message);
    END IF;
  END assert;

BEGIN
  -- Test with an existing email
  assert(EMAIL_EXISTS(v_test_existing_email, 'CUSTOMER') = 1, 'Existing email test');

  -- Test with a non-existing email
  assert(EMAIL_EXISTS(v_test_non_existing_email, 'CUSTOMER') = 0, 'Non-existing email test');
END TEST_EMAIL_EXISTS;
/

-- Run the test procedure for EMAIL_EXISTS
BEGIN
  TEST_EMAIL_EXISTS;
END;
/
