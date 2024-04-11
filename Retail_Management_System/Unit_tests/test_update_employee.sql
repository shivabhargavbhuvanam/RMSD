DECLARE
    -- Variables for test parameters and expected results
    v_test_first_name EMPLOYEE.first_name%TYPE := 'TestFirstName';
    v_test_last_name EMPLOYEE.last_name%TYPE := 'TestLastName';
    v_test_email EMPLOYEE.email%TYPE := 'test@example.com';
    v_test_phone EMPLOYEE.phone_number%TYPE := '(123) 456-7890';
    v_test_hiring_date EMPLOYEE.hiring_date%TYPE := SYSTIMESTAMP;
    v_test_role EMPLOYEE.role%TYPE := 'TestRole';
    v_test_wage EMPLOYEE.wage%TYPE := 10000;
    v_new_first_name EMPLOYEE.first_name%TYPE := 'NewFirstName';
    v_new_last_name EMPLOYEE.last_name%TYPE := 'NewLastName';
    v_employee_id EMPLOYEE.employee_id%TYPE;

    -- Variable for assertion
    v_assert_message VARCHAR2(100);

BEGIN
    -- Setup: Insert a test employee record
    INSERT INTO EMPLOYEE (FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRING_DATE, ROLE, WAGE)
    VALUES (v_test_first_name, v_test_last_name, v_test_email, v_test_phone, v_test_hiring_date, v_test_role, v_test_wage)
    RETURNING EMPLOYEE_ID INTO v_employee_id;

    -- Test Execution: Update the test employee record
    UPDATE_EMPLOYEE_RECORD(v_new_first_name, v_new_last_name, v_test_email, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

    -- Verification: Check if the employee record was updated as expected
    SELECT FIRST_NAME, LAST_NAME INTO v_test_first_name, v_test_last_name FROM EMPLOYEE WHERE EMPLOYEE_ID = v_employee_id;

    IF v_test_first_name = v_new_first_name AND v_test_last_name = v_new_last_name THEN
        v_assert_message := 'Test passed';
    ELSE
        v_assert_message := 'Test failed';
    END IF;

    -- Output the result of the test
    DBMS_OUTPUT.PUT_LINE(v_assert_message);

    -- Teardown: Delete the test employee record
    DELETE FROM EMPLOYEE WHERE EMPLOYEE_ID = v_employee_id;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Handle exceptions
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        ROLLBACK;
END;
/
