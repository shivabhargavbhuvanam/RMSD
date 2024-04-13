CREATE OR REPLACE PROCEDURE TEST_ADD_CUSTOMER_RECORD
AS
    -- Variable to hold output from the procedure
    v_result VARCHAR2(4000);
    -- Expected results for clarity
    v_expected_success_msg VARCHAR2(100) := 'Customer record added successfully';
    v_expected_duplicate_msg VARCHAR2(100) := 'Error: Customer with the same email already exists';
    v_expected_input_error_msg VARCHAR2(100) := 'Error: Invalid input arguments';

BEGIN
    -- Test 1: Adding a valid customer
    ADD_CUSTOMER_RECORD('John', 'Doe', '555-1234', 'john.doe@example.com', 123, 'Main St', 'Anytown', 'State', 'Country', 12345, v_result);
    IF v_result = v_expected_success_msg THEN
        DBMS_OUTPUT.PUT_LINE('Test 1 Passed: ' || v_result);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Test 1 Failed: Expected "' || v_expected_success_msg || '" but got "' || v_result || '"');
    END IF;

    -- Test 2: Attempt to add the same customer again (duplicate email)
    ADD_CUSTOMER_RECORD('John', 'Doe', '555-1234', 'john.doe@example.com', 123, 'Main St', 'Anytown', 'State', 'Country', 12345, v_result);
    IF v_result = v_expected_duplicate_msg THEN
        DBMS_OUTPUT.PUT_LINE('Test 2 Passed: ' || v_result);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Test 2 Failed: Expected "' || v_expected_duplicate_msg || '" but got "' || v_result || '"');
    END IF;

    -- Test 3: Attempt to add a customer with invalid input (null first name)
    ADD_CUSTOMER_RECORD(NULL, 'Doe', '555-1234', 'john.null@example.com', 123, 'Main St', 'Anytown', 'State', 'Country', 12345, v_result);
    IF v_result = v_expected_input_error_msg THEN
        DBMS_OUTPUT.PUT_LINE('Test 3 Passed: ' || v_result);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Test 3 Failed: Expected "' || v_expected_input_error_msg || '" but got "' || v_result || '"');
    END IF;

END TEST_ADD_CUSTOMER_RECORD;
/

-- Execute the unit test procedure
BEGIN
    test_add_customer_record;
END;
/
