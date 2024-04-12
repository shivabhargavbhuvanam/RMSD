SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK ON

BEGIN
    STORE_OWNER.ADD_PRODUCT(
        p_category => 'Clothing',
        p_name => 'Jeans',
        p_selling_price => 26.99
    );
END;
/
BEGIN
    STORE_OWNER.ADD_PRODUCT(
        p_category => 'Kitchen',
        p_name => 'Pan',
        p_selling_price => 9.99
    );
END;
/
BEGIN
    STORE_OWNER.ADD_PRODUCT(
        p_category => 'Furniture',
        p_name => 'Bed frame',
        p_selling_price => 50.99
    );
END;
/
BEGIN
    STORE_OWNER.ADD_PRODUCT(
        p_category => 'Food',
        p_name => 'Lays',
        p_selling_price => 4.99
    );
END;
/


BEGIN
    STORE_OWNER.UPDATE_PRODUCT_NAME_CATEGORY(
            p_product_id => 9,
            p_category => 'Chips'
    );
END;
/


BEGIN
    STORE_OWNER.PROCESS_PURCHASE(
    pi_vendor_id      => 4,
    pi_product_id     => 9,
    pi_units          =>250,
    pi_buying_price   => 3.45
);
END;
/

-- SELECT * FROM STORE_OWNER.STORE_PRODUCTS;
-- SELECT * FROM STORE_OWNER.STORE_PURCHASES;
-- SELECT * FROM STORE_OWNER.LOW_STOCK;
