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
    EMAIL VARCHAR2(25)
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
    EMAIL VARCHAR2(25),
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


-- Inserting data into the Address table
INSERT INTO Address (HOUSE_NUMBER, STREET, CITY, STATE, COUNTRY, POSTAL_CODE) VALUES (101, 'Main St', 'Springfield', 'Massachusetts', 'United States', 12345);
INSERT INTO Address (HOUSE_NUMBER, STREET, CITY, STATE, COUNTRY, POSTAL_CODE) VALUES (102, 'Second St', 'Brookefield', 'Texas', 'United States', 23456);
INSERT INTO Address (HOUSE_NUMBER, STREET, CITY, STATE, COUNTRY, POSTAL_CODE) VALUES (103, 'Third St', 'Elder st', 'California', 'United States', 34567);
INSERT INTO Address (HOUSE_NUMBER, STREET, CITY, STATE, COUNTRY, POSTAL_CODE) VALUES (104, 'Fourth St', 'East cottage st', 'Nebraska', 'United States', 02122);
INSERT INTO Address (HOUSE_NUMBER, STREET, CITY, STATE, COUNTRY, POSTAL_CODE) VALUES (105, 'Fifth St', 'Mass avenue', 'Tenesse', 'United States', 20133);


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
