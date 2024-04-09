BEGIN
    STORE_OWNER.ADD_PRODUCT(
        p_category => 'Clothing',
        p_name => 'Jeans',
        p_remaining_units => 50,
        p_selling_price => 26.99
    );
END;
/
BEGIN
    STORE_OWNER.ADD_PRODUCT(
        p_category => 'Kitchen',
        p_name => 'Pan',
        p_remaining_units => 150,
        p_selling_price => 9.99
    );
END;
/
BEGIN
    STORE_OWNER.ADD_PRODUCT(
        p_category => 'Furniture',
        p_name => 'Recliner',
        p_remaining_units => 10,
        p_selling_price => 97.50
    );
END;
/
BEGIN
    STORE_OWNER.ADD_PRODUCT(
        p_category => 'Furniture',
        p_name => 'Bed frame',
        p_remaining_units => 50,
        p_selling_price => 50.99
    );
END;
/
BEGIN
    STORE_OWNER.ADD_PRODUCT(
        p_category => 'Food',
        p_name => 'Lays',
        p_remaining_units => 150,
        p_selling_price => 4.99
    );
END;
/
