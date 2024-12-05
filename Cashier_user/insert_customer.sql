
SET SERVEROUTPUT ON;

EXEC APP_ADMIN.insert_customer_with_loyalty('JnN', 'Doe', 'jny@example.com', 1214555860, '123 Main St', TRUE, 'GOLD');

EXEC APP_ADMIN.insert_customer_with_loyalty('Jane', 'Smith', 'jane@example.com', 9876543210, '456 Elm St', TRUE, 'SILVER');

-- For a customer not joining the loyalty program
EXEC APP_ADMIN.insert_customer_with_loyalty('Bob', 'Johnson', 'bob@example.com', 5551234567, '789 Oak St', FALSE);