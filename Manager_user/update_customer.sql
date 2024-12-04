SET SERVEROUTPUT ON;
BEGIN
    APP_ADMIN.update_customer(
        p_customer_id => 7,         -- ID of the customer to update
        p_first_name => 'Vihaan',       -- New first name
        p_last_name => 'Patel',         -- New last name
        p_email => 'vihaan.patel@example.com',  -- New email address
        p_phone => '9876543221',    -- New phone number
        p_address => '123 Elm St',    -- New address
        p_loyalty_program_id => 7  -- Loyalty program ID (if applicable)
    );
END;
/