CREATE OR REPLACE PROCEDURE TEST_ADD_CUSTOMER_RECORD
AS
BEGIN
    -- Test 1: Adding a valid customer
    ADD_CUSTOMER_RECORD('John', 'Doe', '555-1234', 'john.doe@example.com', 123, 'Main St', 'Anytown', 'State', 'Country', 12345);
    DBMS_OUTPUT.PUT_LINE('Test 1 Expected Outcome: Customer record added successfully');

    -- Test 2: Attempt to add the same customer again (duplicate email)
    ADD_CUSTOMER_RECORD('John', 'Doe', '555-1234', 'john.doe@example.com', 123, 'Main St', 'Anytown', 'State', 'Country', 12345);
    DBMS_OUTPUT.PUT_LINE('Test 2 Expected Outcome: Error: Customer with the same email already exists');

    -- Test 3: Attempt to add a customer with invalid input (null first name)
    ADD_CUSTOMER_RECORD(NULL, 'Doe', '555-1234', 'john.null@example.com', 123, 'Main St', 'Anytown', 'State', 'Country', 12345);
    DBMS_OUTPUT.PUT_LINE('Test 3 Expected Outcome: Error: Invalid input arguments');

END TEST_ADD_CUSTOMER_RECORD;
/

-- Execute the unit test procedure
BEGIN
    TEST_ADD_CUSTOMER_RECORD;
END;
/
