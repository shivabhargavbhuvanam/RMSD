SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK ON

-- Adding Customer 1
BEGIN
    store_owner.ADD_CUSTOMER_RECORD(
        pi_first_name     => 'Emily',
        pi_last_name      => 'Clark',
        pi_phone          => '555-1122',
        pi_email          => 'emily.clark@example.com',
        pi_house_number   => 101,
        pi_street         => 'Pine Street',
        pi_city           => 'Springfield',
        pi_state          => 'Illinois',
        pi_country        => 'United States',
        pi_postal_code    => 62704
    );
END;
/

-- Adding Customer 2
BEGIN
    store_owner.ADD_CUSTOMER_RECORD(
        pi_first_name     => 'Robert',
        pi_last_name      => 'Brown',
        pi_phone          => '555-2233',
        pi_email          => 'robert.brown@example.com',
        pi_house_number   => 202,
        pi_street         => 'Oak Avenue',
        pi_city           => 'Rivertown',
        pi_state          => 'Mississippi',
        pi_country        => 'United States',
        pi_postal_code    => 38614
    );
END;
/

-- Adding Customer 3
BEGIN
    store_owner.ADD_CUSTOMER_RECORD(
        pi_first_name     => 'Alice',
        pi_last_name      => 'Johnson',
        pi_phone          => '555-3344',
        pi_email          => 'alice.johnson@example.com',
        pi_house_number   => 303,
        pi_street         => 'Birch Lane',
        pi_city           => 'Hilltop',
        pi_state          => 'California',
        pi_country        => 'United States',
        pi_postal_code    => 90210
    );
END;
/

BEGIN

STORE_OWNER.UPDATE_CUSTOMER_RECORD(
    pi_current_email  => 'alice.johnson@example.com',
    pi_new_email      => 'alice.j22@example.com'
);

END;
/


DECLARE
    v_products STORE_OWNER.product_list_type := STORE_OWNER.product_list_type(
        STORE_OWNER.product_type('Nike', 'Shoes', 7),
        STORE_OWNER.product_type('Retinoid', 'Cosmetics', 10),
        STORE_OWNER.product_type('Lays', 'Chips', 15),
        STORE_OWNER.product_type('Pan', 'Kitchen', 2)
    );
BEGIN
    STORE_OWNER.process_products(pi_products=>v_products, pi_customer_email=>'jimbean@email.com', pi_employee_email=>'thomas@email.com');
END;
/

DECLARE
    v_products1 STORE_OWNER.product_list_type := STORE_OWNER.product_list_type(
        STORE_OWNER.product_type('Nike', 'Shoes', 4),
        STORE_OWNER.product_type('Lays', 'Chips', 5),
        STORE_OWNER.product_type('Smartphone', 'Electronics', 1)
    );
BEGIN
    STORE_OWNER.process_products(pi_products=>v_products1, pi_customer_email=>'jimbean@email.com', pi_employee_email=>'jane@email.com');
END;
/

DECLARE
    v_products2 STORE_OWNER.product_list_type := STORE_OWNER.product_list_type(
        STORE_OWNER.product_type('Smartphone', 'Electronics', 2),
        STORE_OWNER.product_type('Jeans', 'Clothing', 5),
        STORE_OWNER.product_type('Retinoid', 'Cosmetics', 3)
    );
BEGIN
    STORE_OWNER.process_products(pi_products=>v_products2, pi_customer_email=>'emily.clark@example.com', pi_employee_email=>'jonesrebecca@email.com');
END;
/

DECLARE
    v_products3 STORE_OWNER.product_list_type := STORE_OWNER.product_list_type(
        STORE_OWNER.product_type('T-Shirt', 'Clothing', 5),
        STORE_OWNER.product_type('Jeans', 'Clothing', 2)
    );
BEGIN
    STORE_OWNER.process_products(pi_products=>v_products3, pi_customer_email=>'alice.j22@example.com', pi_employee_email=>'bobby@email.com');
END;
/

DECLARE
    v_products4 STORE_OWNER.product_list_type := STORE_OWNER.product_list_type(
        STORE_OWNER.product_type('Milk', 'Groceries', 4),
        STORE_OWNER.product_type('Jeans', 'Clothing', 5),
        STORE_OWNER.product_type('Bed frame', 'Furniture', 3),
        STORE_OWNER.product_type('Retinoid', 'Cosmetics', 3),
        STORE_OWNER.product_type('Smartphone', 'Electronics', 2)
    );
BEGIN
    STORE_OWNER.process_products(pi_products=>v_products4, pi_customer_email=>'robert.brown@example.com', pi_employee_email=>'carter@email.com');
END;
/

DECLARE
    v_products5 STORE_OWNER.product_list_type := STORE_OWNER.product_list_type(
        STORE_OWNER.product_type('Jeans', 'Clothing', 5),
        STORE_OWNER.product_type('Retinoid', 'Cosmetics', 3),
        STORE_OWNER.product_type('Milk', 'Groceries', 4),
        STORE_OWNER.product_type('Smartphone', 'Electronics', 2),
        STORE_OWNER.product_type('Bed frame', 'Furniture', 3)
    );
BEGIN
    STORE_OWNER.process_products(pi_products=>v_products5, pi_customer_email=>'johndoe@email.com', pi_employee_email=>'bobby@email.com');
END;
/

DECLARE
    v_products6 STORE_OWNER.product_list_type := STORE_OWNER.product_list_type(
        STORE_OWNER.product_type('Milk', 'Groceries', 4),
        STORE_OWNER.product_type('Retinoid', 'Cosmetics', 3),
        STORE_OWNER.product_type('Bed frame', 'Furniture', 3),
        STORE_OWNER.product_type('Smartphone', 'Electronics', 2),
        STORE_OWNER.product_type('Jeans', 'Clothing', 5)
    );
BEGIN
    STORE_OWNER.process_products(pi_products=>v_products6, pi_customer_email=>'alice.j22@example.com', pi_employee_email=>'carter@email.com');
END;
/

DECLARE
    v_products7 STORE_OWNER.product_list_type := STORE_OWNER.product_list_type(
        STORE_OWNER.product_type('Bed frame', 'Furniture', 3),
        STORE_OWNER.product_type('Milk', 'Groceries', 4),
        STORE_OWNER.product_type('Smartphone', 'Electronics', 2),
        STORE_OWNER.product_type('Jeans', 'Clothing', 5),
        STORE_OWNER.product_type('Retinoid', 'Cosmetics', 3)
    );
BEGIN
    STORE_OWNER.process_products(pi_products=>v_products7, pi_customer_email=>'johndoe@email.com', pi_employee_email=>'bobby@email.com');
END;
/

DECLARE
    v_products8 STORE_OWNER.product_list_type := STORE_OWNER.product_list_type(
        STORE_OWNER.product_type('Jeans', 'Clothing', 5),
        STORE_OWNER.product_type('Milk', 'Groceries', 4),
        STORE_OWNER.product_type('Smartphone', 'Electronics', 2),
        STORE_OWNER.product_type('Bed frame', 'Furniture', 3),
        STORE_OWNER.product_type('Retinoid', 'Cosmetics', 3)
    );
BEGIN
    STORE_OWNER.process_products(pi_products=>v_products8, pi_customer_email=>'robert.brown@example.com', pi_employee_email=>'thomas@email.com');
END;
/

DECLARE
    v_products9 STORE_OWNER.product_list_type := STORE_OWNER.product_list_type(
        STORE_OWNER.product_type('Smartphone', 'Electronics', 2),
        STORE_OWNER.product_type('Jeans', 'Clothing', 5),
        STORE_OWNER.product_type('Milk', 'Groceries', 4),
        STORE_OWNER.product_type('Retinoid', 'Cosmetics', 3),
        STORE_OWNER.product_type('Bed frame', 'Furniture', 3)
    );
BEGIN
    STORE_OWNER.process_products(pi_products=>v_products9, pi_customer_email=>'alice.j22@example.com', pi_employee_email=>'thomas@email.com');
END;
/

DECLARE
    v_products10 STORE_OWNER.product_list_type := STORE_OWNER.product_list_type(
        STORE_OWNER.product_type('Milk', 'Groceries', 4),
        STORE_OWNER.product_type('Jeans', 'Clothing', 5),
        STORE_OWNER.product_type('Retinoid', 'Cosmetics', 3),
        STORE_OWNER.product_type('Smartphone', 'Electronics', 2),
        STORE_OWNER.product_type('Bed frame', 'Furniture', 3)
    );
BEGIN
    STORE_OWNER.process_products(pi_products=>v_products10, pi_customer_email=>'robert.brown@example.com', pi_employee_email=>'thomas@email.com');
END;
/

DECLARE
    v_products11 STORE_OWNER.product_list_type := STORE_OWNER.product_list_type(
        STORE_OWNER.product_type('Smartphone', 'Electronics', 2),
        STORE_OWNER.product_type('Milk', 'Groceries', 4),
        STORE_OWNER.product_type('Jeans', 'Clothing', 5),
        STORE_OWNER.product_type('Bed frame', 'Furniture', 3),
        STORE_OWNER.product_type('Retinoid', 'Cosmetics', 3)
    );
BEGIN
    STORE_OWNER.process_products(pi_products=>v_products11, pi_customer_email=>'alice.j22@example.com', pi_employee_email=>'bobby@email.com');
END;
/

DECLARE
    v_products12 STORE_OWNER.product_list_type := STORE_OWNER.product_list_type(
        STORE_OWNER.product_type('Retinoid', 'Cosmetics', 3),
        STORE_OWNER.product_type('Smartphone', 'Electronics', 2)
    );
BEGIN
    STORE_OWNER.process_products(pi_products=>v_products12, pi_customer_email=>'robert.brown@example.com', pi_employee_email=>'carter@email.com');
END;
/


BEGIN
    STORE_OWNER.UPDATE_ORDER_RECORD(pi_order_id => 4, pi_product_id=>7, pi_updated_units => 1);
END;
/

--SELECT * FROM STORE_OWNER.STORE_ORDERS;
--SELECT * FROM STORE_OWNER.STORE_PRODUCTS;
--SELECT * FROM STORE_OWNER.STORE_CUSTOMERS;
