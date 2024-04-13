SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK ON

-- Add a employee
BEGIN
    STORE_OWNER.ADD_EMPLOYEE_RECORD(
        pi_first_name    => 'Van',
        pi_last_name     => 'Dijk',
        pi_email         => 'vandijk@email.com',
        pi_phone         => '(857)555-6789',
        pi_hiring_date   => SYSTIMESTAMP,
        pi_role          => 'Sales Rep',
        pi_wage          => 70000,
        pi_house_number  => 13,
        pi_street        => 'Elder Street',
        pi_city          => 'Boston',
        pi_state         => 'Massachusetts',
        pi_country       => 'United States',
        pi_postal_code   => 32125
    );
END;
/


BEGIN
    STORE_OWNER.ADD_VENDOR_RECORD(
        pi_name     => 'Smith Enterprises',
        pi_email         => 'joesmith24@example.com',
        pi_phone         => '1234567890',
        pi_house_number  => 56,
        pi_street        => 'Ford Street',
        pi_city          => 'Boston',
        pi_state         => 'Massachusetts',
        pi_country       => 'United States',
        pi_postal_code   => 32343
    );
END;
/

BEGIN
    STORE_OWNER.UPDATE_VENDOR_RECORD(
    pi_email            => 'joesmith24@example.com',
    pi_newEmail         => 'joelsmith24@example.com',
    pi_house_number     => 65
);
END;
/


SELECT * FROM STORE_OWNER.STORE_EMPLOYEES;
SELECT * FROM STORE_OWNER.STORE_VENDORS;
SELECT * FROM STORE_OWNER.STORE_CUSTOMERS;
SELECT * FROM STORE_OWNER.EMPLOYEE_PERFORMANCE;
