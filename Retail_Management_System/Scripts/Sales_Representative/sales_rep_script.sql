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
