create or replace PROCEDURE ADD_EMPLOYEE_RECORD(
    pi_first_name       IN EMPLOYEE.first_name%TYPE,
    pi_last_name        IN EMPLOYEE.last_name%TYPE,
    pi_email            IN EMPLOYEE.email%TYPE,
    pi_phone            IN EMPLOYEE.phone_number%TYPE,
    pi_hiring_date      IN EMPLOYEE.hiring_date%TYPE,
    pi_role             IN EMPLOYEE.role%TYPE,
    pi_house_number     IN ADDRESS.house_number%TYPE,
    pi_street           IN ADDRESS.street%TYPE,
    pi_city             IN ADDRESS.city%TYPE,
    pi_state            IN ADDRESS.state%type,
    pi_country          IN ADDRESS.country%TYPE,
    pi_postal_code      IN ADDRESS.postal_code%TYPE
)
AS
    v_address_id ADDRESS.address_id%TYPE;
    invalid_input EXCEPTION;

BEGIN

        -- Validate input arguments
    IF pi_first_name IS NULL OR pi_last_name IS NULL OR pi_email IS NULL 
        OR pi_phone IS NULL OR pi_hiring_date IS NULL 
        OR pi_house_number IS NULL OR pi_street IS NULL OR pi_role IS NULL
        OR pi_city IS NULL OR pi_state IS NULL 
        OR pi_country IS NULL OR pi_postal_code IS NULL THEN
        RAISE invalid_input;
    END IF;

    -- Insert into Address table
    INSERT INTO ADDRESS (HOUSE_NUMBER, STREET, CITY, STATE, COUNTRY, POSTAL_CODE)
    VALUES (pi_house_number, pi_street, pi_city, pi_state, pi_country, pi_postal_code)
    RETURNING ADDRESS_ID INTO v_address_id;

    -- Insert into Employee table
    INSERT INTO EMPLOYEE (FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRING_DATE, ADDRESS_ID)
    VALUES (pi_first_name, pi_last_name, pi_email, pi_phone, pi_hiring_date, v_address_id);

    COMMIT;

     DBMS_OUTPUT.PUT_LINE('Employee record added successfully');

EXCEPTION
    WHEN invalid_input THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: Invalid input arguments');
     WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error has occured during prodecure execution');

END ADD_EMPLOYEE_RECORD;
/

-- manager has permission to execute this procedure
-- GRANT EXECUTE ON ADD_EMPLOYEE_RECORD TO manager_role;
