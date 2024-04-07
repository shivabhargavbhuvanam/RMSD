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
CREATE TABLE Address (
    ADDRESS_ID NUMBER GENERATED BY DEFAULT AS IDENTITY,
    HOUSE_NUMBER NUMBER,
    STREET VARCHAR2(20),
    CITY VARCHAR2(15),
    STATE VARCHAR2(20),
    COUNTRY VARCHAR2(20),
    POSTAL_CODE NUMBER
);

CREATE TABLE Customer (
    CUSTOMER_ID NUMBER GENERATED BY DEFAULT AS IDENTITY,
    FIRST_NAME VARCHAR2(30),
    LAST_NAME VARCHAR2(30),
    ADDRESS_ID NUMBER,
    PHONE_NUMBER VARCHAR2(15),
    EMAIL VARCHAR2(45)
);

CREATE TABLE Product (
    PRODUCT_ID NUMBER GENERATED BY DEFAULT AS IDENTITY,
    CATEGORY VARCHAR2(35),
    NAME VARCHAR2(35),
    REMAINING_UNITS NUMBER,
    SELLING_PRICE NUMBER
);

CREATE TABLE Orders (
    ORDER_ID NUMBER GENERATED BY DEFAULT AS IDENTITY,
    CUSTOMER_ID NUMBER,
    EMPLOYEE_ID NUMBER,
    ORDER_DATE TIMESTAMP -- Renamed 'DATE' to 'ORDER_DATE'
);

CREATE TABLE Item_Orders (
    ORDER_ID NUMBER,
    PRODUCT_ID NUMBER,
    UNITS NUMBER
);

CREATE TABLE Employee (
    EMPLOYEE_ID NUMBER GENERATED BY DEFAULT AS IDENTITY,
    FIRST_NAME VARCHAR2(30),
    LAST_NAME VARCHAR2(30),
    ADDRESS_ID NUMBER,
    EMAIL VARCHAR2(45),
    PHONE_NUMBER VARCHAR2(15),
    HIRING_DATE TIMESTAMP,
    ROLE VARCHAR2(15),
    WAGE NUMBER
);

CREATE TABLE Purchases (
    TRANSACTION_ID NUMBER GENERATED BY DEFAULT AS IDENTITY,
    PURCHASE_DATE TIMESTAMP,
    VENDOR_ID NUMBER,
    PRODUCT_ID NUMBER,
    QUANTITY NUMBER,
    TOTAL_PRICE NUMBER(10, 2)
);

CREATE TABLE Vendor (
    VENDOR_ID NUMBER GENERATED BY DEFAULT AS IDENTITY,
    NAME VARCHAR2(45),
    ADDRESS_ID NUMBER,
    PHONE_NUMBER VARCHAR2(45),
    EMAIL VARCHAR2(45)
);

ALTER TABLE Address ADD PRIMARY KEY (ADDRESS_ID);
ALTER TABLE Customer ADD PRIMARY KEY (CUSTOMER_ID);
ALTER TABLE Product ADD PRIMARY KEY (PRODUCT_ID);
ALTER TABLE Orders ADD PRIMARY KEY (ORDER_ID);
ALTER TABLE Item_Orders ADD PRIMARY KEY (ORDER_ID, PRODUCT_ID);
ALTER TABLE Employee ADD PRIMARY KEY (EMPLOYEE_ID);
ALTER TABLE Purchases ADD PRIMARY KEY (TRANSACTION_ID);
ALTER TABLE Vendor ADD PRIMARY KEY (VENDOR_ID);

ALTER TABLE Customer ADD CONSTRAINT FK_Customer_Address FOREIGN KEY (ADDRESS_ID) REFERENCES Address(ADDRESS_ID);
ALTER TABLE Orders ADD CONSTRAINT FK_Orders_Customer FOREIGN KEY (CUSTOMER_ID) REFERENCES Customer(CUSTOMER_ID);
ALTER TABLE Orders ADD CONSTRAINT FK_Orders_Employee FOREIGN KEY (EMPLOYEE_ID) REFERENCES Employee(EMPLOYEE_ID);
ALTER TABLE Item_Orders ADD CONSTRAINT FK_ItemOrders_Orders FOREIGN KEY (ORDER_ID) REFERENCES Orders(ORDER_ID);
ALTER TABLE Item_Orders ADD CONSTRAINT FK_ItemOrders_Product FOREIGN KEY (PRODUCT_ID) REFERENCES Product(PRODUCT_ID);
ALTER TABLE Employee ADD CONSTRAINT FK_Employee_Address FOREIGN KEY (ADDRESS_ID) REFERENCES Address(ADDRESS_ID);
ALTER TABLE Purchases ADD CONSTRAINT FK_Purchases_Vendor FOREIGN KEY (VENDOR_ID) REFERENCES Vendor(VENDOR_ID);
ALTER TABLE Purchases ADD CONSTRAINT FK_Purchases_Product FOREIGN KEY (PRODUCT_ID) REFERENCES Product(PRODUCT_ID);
ALTER TABLE Vendor ADD CONSTRAINT FK_Vendor_Address FOREIGN KEY (ADDRESS_ID) REFERENCES Address(ADDRESS_ID);

ALTER TABLE Customer ADD CONSTRAINT Unique_Customer_Email UNIQUE (EMAIL);

ALTER TABLE Employee ADD CONSTRAINT Unique_Employee_Email UNIQUE (EMAIL);

ALTER TABLE Vendor ADD CONSTRAINT Unique_Vendor_Email UNIQUE (EMAIL);


-- View for Customer Order History
CREATE OR REPLACE VIEW Customer_Order_History AS
SELECT c.CUSTOMER_ID, c.FIRST_NAME, c.LAST_NAME, o.ORDER_ID, o.ORDER_DATE
FROM Customer c
JOIN Orders o ON c.CUSTOMER_ID = o.CUSTOMER_ID;


-- View for Vendor Order History
CREATE OR REPLACE VIEW Vendor_Order_History AS
SELECT v.VENDOR_ID, v.NAME, p.TRANSACTION_ID, p.PURCHASE_DATE, p.QUANTITY
FROM Vendor v
JOIN Purchases p ON v.VENDOR_ID = p.VENDOR_ID;

-- View for Current Inventory
CREATE OR REPLACE VIEW Current_Inventory AS
SELECT p.PRODUCT_ID, p.NAME, p.REMAINING_UNITS
FROM Product p;

-- View for Low Stock
-- Assuming 'low stock' is defined as fewer than 10 units
CREATE OR REPLACE VIEW Low_Stock AS
SELECT p.PRODUCT_ID, p.NAME, p.REMAINING_UNITS
FROM Product p
WHERE p.REMAINING_UNITS < 10;

-- View for Product Sales
CREATE OR REPLACE VIEW Product_Sales AS
SELECT p.PRODUCT_ID, p.NAME, SUM(io.UNITS) AS TOTAL_UNITS_SOLD
FROM Product p
JOIN Item_Orders io ON p.PRODUCT_ID = io.PRODUCT_ID
GROUP BY p.PRODUCT_ID, p.NAME;

-- View for Weekly Sales
CREATE OR REPLACE VIEW Weekly_Sales AS
SELECT TO_CHAR(o.ORDER_DATE, 'IW') AS WEEK_NUMBER, SUM(io.UNITS) AS UNITS_SOLD
FROM Orders o
JOIN Item_Orders io ON o.ORDER_ID = io.ORDER_ID
WHERE o.ORDER_DATE BETWEEN TO_DATE('2024-01-01', 'YYYY-MM-DD') AND TO_DATE('2024-12-31', 'YYYY-MM-DD')
GROUP BY TO_CHAR(o.ORDER_DATE, 'IW');

-- View for Weekly Purchases
CREATE OR REPLACE VIEW Weekly_Purchases AS
SELECT TO_CHAR(p.PURCHASE_DATE, 'IW') AS WEEK_NUMBER, SUM(p.QUANTITY) AS QUANTITY_PURCHASED
FROM Purchases p
WHERE p.PURCHASE_DATE BETWEEN TO_DATE('2024-01-01', 'YYYY-MM-DD') AND TO_DATE('2024-12-31', 'YYYY-MM-DD')
GROUP BY TO_CHAR(p.PURCHASE_DATE, 'IW');

-- View for Employee Performance
CREATE OR REPLACE VIEW Employee_Performance AS
SELECT e.EMPLOYEE_ID, e.FIRST_NAME, e.LAST_NAME, COUNT(o.ORDER_ID) AS TOTAL_ORDERS
FROM Employee e
JOIN Orders o ON e.EMPLOYEE_ID = o.EMPLOYEE_ID
GROUP BY e.EMPLOYEE_ID, e.FIRST_NAME, e.LAST_NAME;


DECLARE
  user_exists EXCEPTION;
  role_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(user_exists, -01918); -- Oracle error code for "user not found"
  PRAGMA EXCEPTION_INIT(role_exists, -01924); -- Oracle error code for "role not granted or does not exist"

  PROCEDURE DropUserIfExists(user_name IN VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE 'DROP USER ' || user_name || ' CASCADE';
    DBMS_OUTPUT.PUT_LINE('User ' || user_name || ' dropped');
  EXCEPTION
    WHEN user_exists THEN
      DBMS_OUTPUT.PUT_LINE('User ' || user_name || ' does not exist, will be created');
  END;

  PROCEDURE DropRoleIfExists(role_name IN VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE 'DROP ROLE ' || role_name;
    DBMS_OUTPUT.PUT_LINE('Role ' || role_name || ' dropped');
  EXCEPTION
    WHEN role_exists THEN
      DBMS_OUTPUT.PUT_LINE('Role ' || role_name || ' does not exist, will be created');
  END;

BEGIN
  -- Dropping roles if they exist
  DropRoleIfExists('sales_rep_role');
  DropRoleIfExists('manager_role');
  DropRoleIfExists('inventory_clerk_role');
  DropRoleIfExists('accountant_role');

  -- Dropping users if they exist
  DropUserIfExists('sales_rep');
  DropUserIfExists('manager');
  DropUserIfExists('inventory_clerk');
  DropUserIfExists('accountant');
END;
/

-- Creating the Sales Representative user
CREATE USER sales_rep IDENTIFIED BY SalesRepPassword00;
-- Creating the sales_rep_role
CREATE ROLE sales_rep_role;

-- Granting privileges to the sales_rep_role
GRANT CREATE SESSION TO sales_rep_role;
GRANT SELECT, INSERT ON Customer TO sales_rep_role;
GRANT SELECT, INSERT ON Address TO sales_rep_role;
GRANT SELECT ON Product TO sales_rep_role;
GRANT SELECT, INSERT ON Orders TO sales_rep_role;
GRANT SELECT, INSERT ON Item_Orders TO sales_rep_role;
GRANT SELECT ON Current_Inventory TO sales_rep_role;
GRANT SELECT ON Low_Stock TO sales_rep_role;
GRANT SELECT ON Customer_Order_History TO sales_rep_role;

-- Grant the role to the sales_rep user
GRANT sales_rep_role TO sales_rep;


-- Creating the Manager user
CREATE USER manager IDENTIFIED BY ManPassword00;
GRANT CREATE SESSION TO manager;

CREATE ROLE manager_role;

-- Granting privileges to manager_role
GRANT SELECT, INSERT, UPDATE ON Customer TO manager_role;
GRANT SELECT, INSERT, UPDATE ON Address TO manager_role;
GRANT SELECT, INSERT, UPDATE ON Employee TO manager_role;
GRANT SELECT, INSERT, UPDATE ON Orders TO manager_role;
GRANT SELECT, INSERT, UPDATE ON Item_Orders TO manager_role;
GRANT SELECT ON Product TO manager_role;
GRANT SELECT ON Current_Inventory TO manager_role;
GRANT SELECT ON Low_Stock TO manager_role;
GRANT SELECT ON Customer_Order_History TO manager_role;
GRANT SELECT ON Employee_Performance TO manager_role;
GRANT manager_role TO manager;

-- Creating the inventory_clerk_role
CREATE ROLE inventory_clerk_role;

-- Granting privileges to inventory_clerk_role
GRANT SELECT, INSERT, UPDATE ON Product TO inventory_clerk_role;
GRANT SELECT ON Purchases TO inventory_clerk_role;
GRANT SELECT, INSERT, UPDATE ON Vendor TO inventory_clerk_role;
GRANT SELECT ON Current_Inventory TO inventory_clerk_role;
GRANT SELECT ON Low_Stock TO inventory_clerk_role;

-- Creating the inventory_clerk user and granting the role
CREATE USER inventory_clerk IDENTIFIED BY ClerkPassword00;
GRANT CREATE SESSION TO inventory_clerk;
GRANT inventory_clerk_role TO inventory_clerk;


-- Creating the accountant_role
CREATE ROLE accountant_role;

-- Granting privileges to accountant_role
GRANT SELECT, INSERT, UPDATE ON Purchases TO accountant_role;
GRANT SELECT ON Orders TO accountant_role;
GRANT SELECT ON Item_Orders TO accountant_role;
GRANT SELECT ON Product_Sales TO accountant_role;
GRANT SELECT ON Low_Stock TO accountant_role;
GRANT SELECT ON Weekly_Sales TO accountant_role;
GRANT SELECT ON Weekly_Purchases TO accountant_role;

-- Creating the accountant user and granting the role
CREATE USER accountant IDENTIFIED BY AccountPassword00;
GRANT CREATE SESSION TO accountant;
GRANT accountant_role TO accountant;


-- Procedures

-- Procedure to add an employee record into the employee table
create or replace PROCEDURE ADD_EMPLOYEE_RECORD(
    pi_first_name       IN EMPLOYEE.first_name%TYPE,
    pi_last_name        IN EMPLOYEE.last_name%TYPE,
    pi_email            IN EMPLOYEE.email%TYPE,
    pi_phone            IN EMPLOYEE.phone_number%TYPE,
    pi_hiring_date      IN EMPLOYEE.hiring_date%TYPE,
    pi_role             IN EMPLOYEE.role%TYPE,
    pi_wage             IN EMPLOYEE.wage%TYPE,
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
        OR pi_house_number IS NULL OR pi_street IS NULL OR pi_role IS NULL or pi_wage IS NULL
        OR pi_city IS NULL OR pi_state IS NULL 
        OR pi_country IS NULL OR pi_postal_code IS NULL THEN
        RAISE invalid_input;
    END IF;

    -- Insert into Address table
    INSERT INTO ADDRESS (HOUSE_NUMBER, STREET, CITY, STATE, COUNTRY, POSTAL_CODE)
    VALUES (pi_house_number, pi_street, pi_city, pi_state, pi_country, pi_postal_code)
    RETURNING ADDRESS_ID INTO v_address_id;

    DBMS_OUTPUT.PUT_LINE('Employee address added successfully');

    -- Insert into Employee table
    INSERT INTO EMPLOYEE (FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRING_DATE, ROLE, WAGE, ADDRESS_ID)
    VALUES (pi_first_name, pi_last_name, pi_email, pi_phone, pi_hiring_date, pi_role, pi_wage, v_address_id);

    COMMIT;

     DBMS_OUTPUT.PUT_LINE('Employee record added successfully');

EXCEPTION
    WHEN invalid_input THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: Invalid input arguments');
     WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: Email already exists');

END ADD_EMPLOYEE_RECORD;
/

GRANT EXECUTE ON ADD_EMPLOYEE_RECORD TO MANAGER_ROLE;


BEGIN
    ADD_EMPLOYEE_RECORD(
        pi_first_name    => 'Jane',
        pi_last_name     => 'Doe',
        pi_email         => 'jane@email.com',
        pi_phone         => '(857)555-6789',
        pi_hiring_date   => SYSTIMESTAMP,
        pi_role          => 'Accountant',
        pi_wage          => 60000,
        pi_house_number  => 123,
        pi_street        => 'Main Street',
        pi_city          => 'Boston',
        pi_state         => 'Massachusetts',
        pi_country       => 'United States',
        pi_postal_code   => 12345
    );
END;
/

BEGIN
    ADD_EMPLOYEE_RECORD(
        pi_first_name    => 'James',
        pi_last_name     => 'Carter',
        pi_email         => 'carter@email.com',
        pi_phone         => '(857)544-3789',
        pi_hiring_date   => SYSTIMESTAMP,
        pi_role          => 'Sales Rep',
        pi_wage          => 50000,
        pi_house_number  => 12,
        pi_street        => 'Stowe Street',
        pi_city          => 'Boston',
        pi_state         => 'Massachusetts',
        pi_country       => 'United States',
        pi_postal_code   => 13245
    );
END;
/

BEGIN
    ADD_EMPLOYEE_RECORD(
        pi_first_name    => 'Charles',
        pi_last_name     => 'Miller',
        pi_email         => 'miller@email.com',
        pi_phone         => '(857)544-4769',
        pi_hiring_date   => SYSTIMESTAMP,
        pi_role          => 'Inventory Clerk',
        pi_wage          => 35000,
        pi_house_number  => 18,
        pi_street        => 'Adams Street',
        pi_city          => 'Boston',
        pi_state         => 'Massachusetts',
        pi_country       => 'United States',
        pi_postal_code   => 13245
    );
END;
/

BEGIN
    ADD_EMPLOYEE_RECORD(
        pi_first_name    => 'Rebecca',
        pi_last_name     => 'Jones',
        pi_email         => 'jonesrebecca@email.com',
        pi_phone         => '(857)344-4659',
        pi_hiring_date   => SYSTIMESTAMP,
        pi_role          => 'Inventory Clerk',
        pi_wage          => 35000,
        pi_house_number  => 22,
        pi_street        => 'JK Street',
        pi_city          => 'Boston',
        pi_state         => 'Massachusetts',
        pi_country       => 'United States',
        pi_postal_code   => 13245
    );
END;
/

BEGIN
    ADD_EMPLOYEE_RECORD(
        pi_first_name    => 'Marie',
        pi_last_name     => 'Thomas',
        pi_email         => 'thomas@email.com',
        pi_phone         => '(855)364-6769',
        pi_hiring_date   => SYSTIMESTAMP,
        pi_role          => 'Sales rep',
        pi_wage          => 66000,
        pi_house_number  => 145,
        pi_street        => 'Harlem Street',
        pi_city          => 'Cambridge',
        pi_state         => 'Massachusetts',
        pi_country       => 'United States',
        pi_postal_code   => 25245
    );
END;
/

BEGIN
    ADD_EMPLOYEE_RECORD(
        pi_first_name    => 'Marie',
        pi_last_name     => 'Thomas',
        pi_email         => 'thomas@email.com',
        pi_phone         => '(855)364-6769',
        pi_hiring_date   => SYSTIMESTAMP,
        pi_role          => 'Sales rep',
        pi_wage          => 66000,
        pi_house_number  => 145,
        pi_street        => 'Harlem Street',
        pi_city          => 'Cambridge',
        pi_state         => 'Massachusetts',
        pi_country       => 'United States',
        pi_postal_code   => 25245
    );
END;
/

CREATE OR REPLACE PROCEDURE ADD_VENDOR_RECORD(
    pi_name             IN VENDOR.NAME%TYPE,
    pi_email            IN VENDOR.EMAIL%TYPE,
    pi_phone            IN VENDOR.PHONE_NUMBER%TYPE,
    pi_house_number     IN ADDRESS.HOUSE_NUMBER%TYPE,
    pi_street           IN ADDRESS.STREET%TYPE,
    pi_city             IN ADDRESS.CITY%TYPE,
    pi_state            IN ADDRESS.STATE%TYPE,
    pi_country          IN ADDRESS.COUNTRY%TYPE,
    pi_postal_code      IN ADDRESS.POSTAL_CODE%TYPE
)
AS
    vendor_address_id ADDRESS.ADDRESS_ID%TYPE;
    invalid_input EXCEPTION;
BEGIN
    IF pi_name IS NULL OR pi_email IS NULL OR pi_phone IS NULL
        OR pi_house_number IS NULL OR pi_street IS NULL
        OR pi_city IS NULL OR pi_state IS NULL
        OR pi_country IS NULL OR pi_postal_code IS NULL THEN
        RAISE invalid_input;
    END IF;
    
    -- Insert into Address table
    INSERT INTO ADDRESS (HOUSE_NUMBER, STREET, CITY, STATE, COUNTRY, POSTAL_CODE)
    VALUES (pi_house_number, pi_street, pi_city, pi_state, pi_country, pi_postal_code)
    RETURNING ADDRESS_ID INTO vendor_address_id;
    DBMS_OUTPUT.PUT_LINE('Vendor address added successfully');
    -- Insert into Vendor table
    INSERT INTO VENDOR (NAME, EMAIL, PHONE_NUMBER, ADDRESS_ID)
    VALUES (pi_name, pi_email, pi_phone, vendor_address_id); -- Corrected to use pi_name instead of name
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Vendor record added successfully');
EXCEPTION
    WHEN invalid_input THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: Invalid input arguments');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error has occurred during procedure execution');
    
END ADD_VENDOR_RECORD;
/
  
GRANT EXECUTE ON ADD_VENDOR_RECORD TO MANAGER_ROLE;

BEGIN
    ADD_VENDOR_RECORD(
        pi_name     => 'vendor A',
        pi_email         => 'vendor.a@example.com',
        pi_phone         => '1234567890',
        pi_house_number  => 123,
        pi_street        => 'Main Street',
        pi_city          => 'Springfield',
        pi_state         => 'Massachusetts',
        pi_country       => 'United States',
        pi_postal_code   => 12345
    );
END;
/
BEGIN
    ADD_VENDOR_RECORD(
        pi_name     => 'vendor B',
        pi_email         => 'vendor.b@example.com',
        pi_phone         => '1234567891',
        pi_house_number  => 234,
        pi_street        => 'Third St',
        pi_city          => 'Elder st',
        pi_state         => 'California',
        pi_country       => 'United States',
        pi_postal_code   => 12345
    );
END;
/
BEGIN
    ADD_VENDOR_RECORD(
        pi_name     => 'vendor C',
        pi_email         => 'vendor.c@example.com',
        pi_phone         => '1234567892',
        pi_house_number  => 345,
        pi_street        => 'Fourth St',
        pi_city          => 'East cottage st',
        pi_state         => 'Nebraska',
        pi_country       => 'United States',
        pi_postal_code   => 02122
    );
END;
/
BEGIN
    ADD_VENDOR_RECORD(
        pi_name     => 'vendor D',
        pi_email         => 'vendor.d@example.com',
        pi_phone         => '1234567893',
        pi_house_number  => 456,
        pi_street        => 'Main Street',
        pi_city          => 'Anytown',
        pi_state         => 'State',
        pi_country       => 'United States',
        pi_postal_code   => 12345
    );
END;
/
BEGIN
    ADD_VENDOR_RECORD(
        pi_name     => 'vendor E',
        pi_email         => 'vendor.e@example.com',
        pi_phone         => '1234567894',
        pi_house_number  => 567,
        pi_street        => 'Fifth St',
        pi_city          => 'Mass avenue',
        pi_state         => 'Tenesse',
        pi_country       => 'United States',
        pi_postal_code   => 20133
    );
END;
/

CREATE OR REPLACE PROCEDURE ADD_CUSTOMER_RECORD(
    pi_first_name     IN CUSTOMER.FIRST_NAME%TYPE,
    pi_last_name      IN CUSTOMER.LAST_NAME%TYPE,
    pi_phone          IN CUSTOMER.PHONE_NUMBER%TYPE,
    pi_email          IN CUSTOMER.EMAIL%TYPE,
    pi_house_number   IN ADDRESS.HOUSE_NUMBER%TYPE,
    pi_street         IN ADDRESS.STREET%TYPE,
    pi_city           IN ADDRESS.CITY%TYPE,
    pi_state          IN ADDRESS.STATE%TYPE,
    pi_country        IN ADDRESS.COUNTRY%TYPE,
    pi_postal_code    IN ADDRESS.POSTAL_CODE%TYPE
)
AS
    v_address_id ADDRESS.ADDRESS_ID%TYPE;
    invalid_input EXCEPTION;
BEGIN
    -- Validate input arguments
    IF pi_first_name IS NULL OR pi_last_name IS NULL OR pi_email IS NULL 
       OR pi_phone IS NULL OR pi_house_number IS NULL OR pi_street IS NULL 
       OR pi_city IS NULL OR pi_state IS NULL 
       OR pi_country IS NULL OR pi_postal_code IS NULL THEN
        RAISE invalid_input;
    END IF;

    -- Insert into Address table
    INSERT INTO ADDRESS (HOUSE_NUMBER, STREET, CITY, STATE, COUNTRY, POSTAL_CODE)
    VALUES (pi_house_number, pi_street, pi_city, pi_state, pi_country, pi_postal_code)
    RETURNING ADDRESS_ID INTO v_address_id;

    -- Insert into Customer table
    INSERT INTO CUSTOMER (FIRST_NAME, LAST_NAME, ADDRESS_ID, PHONE_NUMBER, EMAIL)
    VALUES (pi_first_name, pi_last_name, v_address_id, pi_phone, pi_email);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Customer record added successfully');

EXCEPTION
    WHEN invalid_input THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: Invalid input arguments');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE(SQLERRM); -- Display the specific SQL error
END ADD_CUSTOMER_RECORD;
/

-- Grant execute permission to appropriate roles or users
GRANT EXECUTE ON ADD_CUSTOMER_RECORD TO manager_role;
GRANT EXECUTE ON ADD_CUSTOMER_RECORD TO sales_rep_role;

-- For John Doe
BEGIN
    ADD_CUSTOMER_RECORD(
        pi_first_name     => 'John',
        pi_last_name      => 'Doe',
        pi_phone          => '555-1234',
        pi_email          => 'johndoe@email.com',
        pi_house_number  => 567,
        pi_street        => 'Fifth St',
        pi_city          => 'Mass avenue',
        pi_state         => 'Tenesse',
        pi_country       => 'United States',
        pi_postal_code   => 20133
    );
END;
/

-- For Jane Smith
BEGIN
    ADD_CUSTOMER_RECORD(
        pi_first_name     => 'Jane',
        pi_last_name      => 'Smith',
        pi_phone          => '555-2345',
        pi_email          => 'janesmith@email.com',
        pi_house_number  => 456,
        pi_street        => 'Main Street',
        pi_city          => 'Anytown',
        pi_state         => 'State',
        pi_country       => 'United States',
        pi_postal_code   => 12345
    );
END;
/

-- For Jim Bean
BEGIN
    ADD_CUSTOMER_RECORD(
        pi_first_name     => 'Jim',
        pi_last_name      => 'Bean',
        pi_phone          => '555-3456',
        pi_email          => 'jimbean@email.com',
        pi_house_number  => 345,
        pi_street        => 'Fourth St',
        pi_city          => 'East cottage st',
        pi_state         => 'Nebraska',
        pi_country       => 'United States',
        pi_postal_code   => 02122
    );
END;
/

-- For James Barnes
BEGIN
    ADD_CUSTOMER_RECORD(
        pi_first_name     => 'James',
        pi_last_name      => 'Barnes',
        pi_phone          => '555-4567',
        pi_email          => 'jamesbarnes@email.com',
        pi_house_number  => 234,
        pi_street        => 'Third St',
        pi_city          => 'Elder st',
        pi_state         => 'California',
        pi_country       => 'United States',
        pi_postal_code   => 12345
    );
END;
/

-- For Jake Bond
BEGIN
    ADD_CUSTOMER_RECORD(
        pi_first_name     => 'Jake',
        pi_last_name      => 'Bond',
        pi_phone          => '555-5678',
        pi_email          => 'jakebond@email.com',
        pi_house_number  => 123,
        pi_street        => 'Main Street',
        pi_city          => 'Springfield',
        pi_state         => 'Massachusetts',
        pi_country       => 'United States',
        pi_postal_code   => 12345
    );
END;
/


-- Inserting data into the Product table
INSERT INTO Product (CATEGORY, NAME, REMAINING_UNITS, SELLING_PRICE) VALUES ('Electronics', 'Smartphone', 50, 299.99);
INSERT INTO Product (CATEGORY, NAME, REMAINING_UNITS, SELLING_PRICE) VALUES ('Clothing', 'T-Shirt', 150, 19.99);
INSERT INTO Product (CATEGORY, NAME, REMAINING_UNITS, SELLING_PRICE) VALUES ('Groceries', 'Milk', 200, 2.99);
INSERT INTO Product (CATEGORY, NAME, REMAINING_UNITS, SELLING_PRICE) VALUES ('Cosmetics', 'Retinoid', 150, 9.99);
INSERT INTO Product (CATEGORY, NAME, REMAINING_UNITS, SELLING_PRICE) VALUES ('Shoes', 'Nike', 50, 39.99);


-- Inserting data into the Orders table (assuming the date format 'YYYY-MM-DD HH24:MI:SS')
INSERT INTO Orders (CUSTOMER_ID, EMPLOYEE_ID, ORDER_DATE) VALUES (1, 1, TO_TIMESTAMP('2024-03-20 10:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Orders (CUSTOMER_ID, EMPLOYEE_ID, ORDER_DATE) VALUES (2, 2, TO_TIMESTAMP('2024-03-20 10:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Orders (CUSTOMER_ID, EMPLOYEE_ID, ORDER_DATE) VALUES (3, 3, TO_TIMESTAMP('2024-03-20 11:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Orders (CUSTOMER_ID, EMPLOYEE_ID, ORDER_DATE) VALUES (4, 1, TO_TIMESTAMP('2024-03-20 10:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Orders (CUSTOMER_ID, EMPLOYEE_ID, ORDER_DATE) VALUES (5, 4, TO_TIMESTAMP('2024-03-20 11:00:00', 'YYYY-MM-DD HH24:MI:SS'));


-- Inserting data into the Item_Orders table
INSERT INTO Item_Orders (ORDER_ID, PRODUCT_ID, UNITS) VALUES (1, 1, 2);
INSERT INTO Item_Orders (ORDER_ID, PRODUCT_ID, UNITS) VALUES (2, 2, 3);
INSERT INTO Item_Orders (ORDER_ID, PRODUCT_ID, UNITS) VALUES (3, 3, 1);
INSERT INTO Item_Orders (ORDER_ID, PRODUCT_ID, UNITS) VALUES (4, 5, 3);
INSERT INTO Item_Orders (ORDER_ID, PRODUCT_ID, UNITS) VALUES (5, 2, 8);

-- Inserting data into the Purchases table
INSERT INTO Purchases (PURCHASE_DATE, VENDOR_ID, PRODUCT_ID, QUANTITY, TOTAL_PRICE) VALUES (TO_TIMESTAMP('2024-01-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 1, 50, 12500.00);
INSERT INTO Purchases (PURCHASE_DATE, VENDOR_ID, PRODUCT_ID, QUANTITY, TOTAL_PRICE) VALUES (TO_TIMESTAMP('2024-01-02 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 2, 150, 2250.00);
INSERT INTO Purchases (PURCHASE_DATE, VENDOR_ID, PRODUCT_ID, QUANTITY, TOTAL_PRICE) VALUES (TO_TIMESTAMP('2024-01-03 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 3, 3, 200, 200.00);
INSERT INTO Purchases (PURCHASE_DATE, VENDOR_ID, PRODUCT_ID, QUANTITY, TOTAL_PRICE) VALUES (TO_TIMESTAMP('2024-01-03 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 4, 4, 150, 900.00);
INSERT INTO Purchases (PURCHASE_DATE, VENDOR_ID, PRODUCT_ID, QUANTITY, TOTAL_PRICE) VALUES (TO_TIMESTAMP('2024-01-03 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 5, 5, 50, 1900.00);


create or replace PROCEDURE UPDATE_EMPLOYEE_RECORD(
    pi_new_first_name       IN EMPLOYEE.first_name%TYPE DEFAULT NULL,
    pi_new_last_name        IN EMPLOYEE.last_name%TYPE DEFAULT NULL,
    pi_current_email        IN EMPLOYEE.email%TYPE,
    pi_new_email            IN EMPLOYEE.email%TYPE DEFAULT NULL,
    pi_new_phone            IN EMPLOYEE.phone_number%TYPE DEFAULT NULL,
    pi_new_hiring_date      IN EMPLOYEE.hiring_date%TYPE DEFAULT NULL,
    pi_new_role             IN EMPLOYEE.role%TYPE DEFAULT NULL,
    pi_new_wage             IN EMPLOYEE.wage%TYPE DEFAULT NULL,
    pi_new_house_number     IN ADDRESS.house_number%TYPE DEFAULT NULL,
    pi_new_street           IN ADDRESS.street%TYPE DEFAULT NULL,
    pi_new_city             IN ADDRESS.city%TYPE DEFAULT NULL,
    pi_new_state            IN ADDRESS.state%type DEFAULT NULL,
    pi_new_country          IN ADDRESS.country%TYPE DEFAULT NULL,
    pi_new_postal_code      IN ADDRESS.postal_code%TYPE DEFAULT NULL
)
AS
    v_address_id ADDRESS.address_id%TYPE;
    v_employee_id EMPLOYEE.employee_id%TYPE;
    v_employee_count INTEGER;
    invalid_input EXCEPTION;

BEGIN

        -- Validate input arguments
    IF  pi_current_email IS NULL 
    THEN
        RAISE invalid_input;
    END IF;
    
    BEGIN
    
        SELECT ADDRESS_ID, EMPLOYEE_ID INTO v_address_id, v_employee_id FROM EMPLOYEE WHERE EMAIL = pi_current_email;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Could not find employee record with specified email');
            RAISE_APPLICATION_ERROR(-200001, 'Could not update employee ');
    
    END;

    UPDATE ADDRESS 
    SET HOUSE_NUMBER = COALESCE(pi_new_house_number,HOUSE_NUMBER), 
        STREET       = COALESCE(pi_new_street,STREET), 
        CITY         = COALESCE(pi_new_city,CITY), 
        STATE        = COALESCE(pi_new_state,STATE), 
        COUNTRY      = COALESCE(pi_new_country,COUNTRY), 
        POSTAL_CODE  = COALESCE(pi_new_postal_code,POSTAL_CODE)
    WHERE ADDRESS_ID = v_address_id;
    
    IF pi_new_email IS NOT NULL THEN
        SELECT COUNT(*) INTO v_employee_count
        FROM EMPLOYEE
        WHERE EMAIL = pi_new_email;

        IF v_employee_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('New email provided already exists');
            RAISE_APPLICATION_ERROR(-20002, 'New email provided already exists');
        END IF;
        IF v_employee_count = 0 THEN
            UPDATE EMPLOYEE SET EMAIL = pi_new_email
                WHERE EMAIL = pi_current_email;
        END IF;
    END IF;
    
    UPDATE Employee
    SET FIRST_NAME   = COALESCE(pi_new_first_name, FIRST_NAME),
        LAST_NAME    = COALESCE(pi_new_last_name, LAST_NAME),
        PHONE_NUMBER = COALESCE(pi_new_phone, PHONE_NUMBER),
        HIRING_DATE  = COALESCE(pi_new_hiring_date, HIRING_DATE),
        ROLE         = COALESCE(pi_new_role, ROLE),
        WAGE         = COALESCE(pi_new_wage, WAGE)
    WHERE EMPLOYEE_ID = v_employee_id;

    COMMIT;

     DBMS_OUTPUT.PUT_LINE('Employee details updated successfully');

EXCEPTION
    WHEN invalid_input THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: You need to provide a valid existing current email');
     WHEN OTHERS THEN
        ROLLBACK;

END UPDATE_EMPLOYEE_RECORD;
/

GRANT EXECUTE ON UPDATE_EMPLOYEE_RECORD TO MANAGER_ROLE;

CREATE OR REPLACE PROCEDURE UPDATE_VENDOR_RECORD(
    pi_email            IN VENDOR.EMAIL%TYPE,
    pi_name             IN VENDOR.NAME%TYPE DEFAULT NULL,
    pi_phone            IN VENDOR.PHONE_NUMBER%TYPE DEFAULT NULL,
    pi_newEmail         IN VENDOR.EMAIL%TYPE DEFAULT NULL,
    pi_house_number     IN ADDRESS.HOUSE_NUMBER%TYPE DEFAULT NULL,
    pi_street           IN ADDRESS.STREET%TYPE DEFAULT NULL,
    pi_city             IN ADDRESS.CITY%TYPE DEFAULT NULL,
    pi_state            IN ADDRESS.STATE%TYPE DEFAULT NULL,
    pi_country          IN ADDRESS.COUNTRY%TYPE DEFAULT NULL,
    pi_postal_code      IN ADDRESS.POSTAL_CODE%TYPE DEFAULT NULL
)
AS
    vendor_count INTEGER;
BEGIN
    -- Check if vendor exists with the given email
    SELECT COUNT(*) INTO vendor_count
    FROM VENDOR
    WHERE EMAIL = pi_email;

    IF vendor_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Vendor not found with the provided email');
        RAISE_APPLICATION_ERROR(-20001, 'Vendor not found with the provided email');
    END IF;

    -- Update Vendor table
    UPDATE VENDOR
    SET NAME = NVL(pi_name, NAME),
        PHONE_NUMBER = NVL(pi_phone, PHONE_NUMBER)
    WHERE EMAIL = pi_email;
    
    DBMS_OUTPUT.PUT_LINE('Vendor name and phone updated');

    -- Update Address table
    -- Assuming an address record exists and is linked to the vendor
    UPDATE ADDRESS
    SET HOUSE_NUMBER = NVL(pi_house_number, HOUSE_NUMBER),
        STREET = NVL(pi_street, STREET),
        CITY = NVL(pi_city, CITY),
        STATE = NVL(pi_state, STATE),
        COUNTRY = NVL(pi_country, COUNTRY),
        POSTAL_CODE = NVL(pi_postal_code, POSTAL_CODE)
    WHERE ADDRESS_ID = (SELECT ADDRESS_ID FROM VENDOR WHERE EMAIL = pi_email);
    
    DBMS_OUTPUT.PUT_LINE('Address updated');
        -- If a new email is provided, check if it's unique
    IF pi_newEmail IS NOT NULL THEN
        SELECT COUNT(*) INTO vendor_count
        FROM VENDOR
        WHERE EMAIL = pi_newEmail;
        DBMS_OUTPUT.PUT_LINE('New email provided updated');

        IF vendor_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('New email provided already exists');
            RAISE_APPLICATION_ERROR(-20002, 'New email provided already exists');
        END IF;
        IF vendor_count = 0 THEN
            UPDATE VENDOR SET EMAIL = pi_newEmail
                WHERE EMAIL = pi_email;
        END IF;
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Vendor record updated successfully');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('An error has occurred during procedure execution');
END UPDATE_VENDOR_RECORD;
/

GRANT EXECUTE ON UPDATE_VENDOR_RECORD TO MANAGER_ROLE;


CREATE OR REPLACE FUNCTION VALIDATE_EMAIL(p_email IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
    -- Check if the email is non-empty and contains '@' and '.'
    IF p_email IS NOT NULL AND INSTR(p_email, '@') > 1 AND INSTR(p_email, '.', INSTR(p_email, '@')) > INSTR(p_email, '@') + 1 THEN
        RETURN TRUE; -- Valid Email
    ELSE
        RETURN FALSE; -- Invalid Email
    END IF;
END VALIDATE_EMAIL;
/

CREATE OR REPLACE PROCEDURE UPDATE_CUSTOMER_RECORD(
    pi_current_email IN CUSTOMER.EMAIL%TYPE,
    pi_new_email     IN CUSTOMER.EMAIL%TYPE DEFAULT NULL,
    pi_first_name    IN CUSTOMER.FIRST_NAME%TYPE DEFAULT NULL,
    pi_last_name     IN CUSTOMER.LAST_NAME%TYPE DEFAULT NULL,
    pi_phone         IN CUSTOMER.PHONE_NUMBER%TYPE DEFAULT NULL,
    pi_house_number  IN ADDRESS.HOUSE_NUMBER%TYPE DEFAULT NULL,
    pi_street        IN ADDRESS.STREET%TYPE DEFAULT NULL,
    pi_city          IN ADDRESS.CITY%TYPE DEFAULT NULL,
    pi_state         IN ADDRESS.STATE%TYPE DEFAULT NULL,
    pi_country       IN ADDRESS.COUNTRY%TYPE DEFAULT NULL,
    pi_postal_code   IN ADDRESS.POSTAL_CODE%TYPE DEFAULT NULL
)
AS
    v_address_id ADDRESS.ADDRESS_ID%TYPE;
    email_already_exists EXCEPTION;
    invalid_email EXCEPTION;
    customer_not_found EXCEPTION;
BEGIN
    -- Validate the new email if provided
    IF pi_new_email IS NOT NULL AND NOT VALIDATE_EMAIL(pi_new_email) THEN
        RAISE invalid_email;
    END IF;

    -- Check if the new email already exists for another customer
    IF pi_new_email IS NOT NULL THEN
        DECLARE
            v_email_count INT;
        BEGIN
            SELECT COUNT(*)
            INTO v_email_count
            FROM CUSTOMER
            WHERE EMAIL = pi_new_email AND EMAIL != pi_current_email;

            IF v_email_count > 0 THEN
                RAISE email_already_exists;
            END IF;
        END;
    END IF;

    -- Check if customer exists and get address ID
    SELECT ADDRESS_ID INTO v_address_id FROM CUSTOMER WHERE EMAIL = pi_current_email;

    -- Update Customer table
    IF pi_first_name IS NOT NULL OR pi_last_name IS NOT NULL OR 
       pi_phone IS NOT NULL OR pi_new_email IS NOT NULL THEN

        UPDATE CUSTOMER
        SET FIRST_NAME = COALESCE(pi_first_name, FIRST_NAME),
            LAST_NAME = COALESCE(pi_last_name, LAST_NAME),
            PHONE_NUMBER = COALESCE(pi_phone, PHONE_NUMBER),
            EMAIL = COALESCE(pi_new_email, EMAIL)
        WHERE EMAIL = pi_current_email;
    END IF;

    -- Update Address table
    IF pi_house_number IS NOT NULL OR pi_street IS NOT NULL OR pi_city IS NOT NULL OR
       pi_state IS NOT NULL OR pi_country IS NOT NULL OR pi_postal_code IS NOT NULL THEN

        UPDATE ADDRESS
        SET HOUSE_NUMBER = COALESCE(pi_house_number, HOUSE_NUMBER),
            STREET = COALESCE(pi_street, STREET),
            CITY = COALESCE(pi_city, CITY),
            STATE = COALESCE(pi_state, STATE),
            COUNTRY = COALESCE(pi_country, COUNTRY),
            POSTAL_CODE = COALESCE(pi_postal_code, POSTAL_CODE)
        WHERE ADDRESS_ID = v_address_id;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Customer and address records updated successfully');

    COMMIT;
EXCEPTION
    WHEN invalid_email THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: Provided new email is invalid');
    WHEN email_already_exists THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: New email already in use by another customer');
    WHEN NO_DATA_FOUND THEN
        RAISE customer_not_found;
    WHEN customer_not_found THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: Customer record not found');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END UPDATE_CUSTOMER_RECORD;
/


GRANT EXECUTE ON UPDATE_CUSTOMER_RECORD TO manager_role;
GRANT EXECUTE ON UPDATE_CUSTOMER_RECORD TO sales_rep_role;

CREATE OR REPLACE PROCEDURE DELETE_CUSTOMER_RECORD(
    pi_email IN CUSTOMER.EMAIL%TYPE
)
AS
    v_customer_id CUSTOMER.CUSTOMER_ID%TYPE;
    v_address_id ADDRESS.ADDRESS_ID%TYPE;
    customer_not_found EXCEPTION;
BEGIN
    -- Retrieve customer ID and address ID based on email
    SELECT CUSTOMER_ID, ADDRESS_ID INTO v_customer_id, v_address_id 
    FROM CUSTOMER WHERE EMAIL = pi_email;

    -- Delete the customer record
    DELETE FROM CUSTOMER WHERE CUSTOMER_ID = v_customer_id;

    -- Delete the address record
    DELETE FROM ADDRESS WHERE ADDRESS_ID = v_address_id;

    DBMS_OUTPUT.PUT_LINE('Customer and address records deleted successfully');

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE customer_not_found;
    WHEN customer_not_found THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: Customer record not found');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END DELETE_CUSTOMER_RECORD;
/