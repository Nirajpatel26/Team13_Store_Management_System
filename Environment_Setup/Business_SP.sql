SET SERVEROUTPUT ON;

BEGIN
    FOR obj IN (SELECT object_name, object_type FROM user_objects WHERE object_type IN ('PROCEDURE') AND object_name IN (
        'ADD_ORDER','INSERT_CUSTOMER_WITH_LOYALTY','RECOMMEND_RELATED_PRODUCTS', 'UPDATE_ORDER_STATUS', 'GENERATE_SALES_REPORT',
        'UPDATE_REORDER_REQUEST','UPDATE_PRODUCT_AND_INVENTORY_STOCK', 'UPDATE_REORDER_STATUS','UPDATE_CUSTOMER','DELETE_ORDER'
    )) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP ' || obj.object_type || ' ' || obj.object_name;
            DBMS_OUTPUT.PUT_LINE('Dropped ' || obj.object_type || ': ' || obj.object_name);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Could not drop ' || obj.object_type || ': ' || obj.object_name || ': ' || SQLERRM);
        END;
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE add_order(
    p_customer_email IN VARCHAR2,
    p_order_date IN DATE,
    p_pay_type IN VARCHAR2,
    p_order_details IN SYS.ODCIVARCHAR2LIST,
    p_employee_id IN NUMBER DEFAULT NULL
) AS
    v_order_id NUMBER;
    v_customer_id NUMBER;
    v_total_amount NUMBER := 0;
    v_pay_id NUMBER;
    v_product_id NUMBER;
    v_quantity NUMBER;
    v_price NUMBER;
    v_available_stock NUMBER;
    v_inventory_id NUMBER;
    v_employee_exists NUMBER;
    
    -- Define a custom exception for invalid payment type
    e_invalid_payment_type EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_invalid_payment_type, -20008);
    
    -- Define valid payment types
    TYPE t_valid_payment_types IS TABLE OF VARCHAR2(20);
    v_valid_payment_types t_valid_payment_types := t_valid_payment_types('Credit Card', 'Debit Card', 'Cash', 'UPI');
    
    -- Function to check if payment type is valid
    FUNCTION is_valid_payment_type(p_type VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        FOR i IN 1..v_valid_payment_types.COUNT LOOP
            IF UPPER(p_type) = UPPER(v_valid_payment_types(i)) THEN
                RETURN TRUE;
            END IF;
        END LOOP;
        RETURN FALSE;
    END;
BEGIN
    -- Validate input parameters
    IF p_customer_email IS NULL OR p_order_date IS NULL OR p_pay_type IS NULL OR p_order_details IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'All input parameters are required.');
    END IF;

    -- Validate payment type
    IF NOT is_valid_payment_type(p_pay_type) THEN
        RAISE e_invalid_payment_type;
    END IF;

    -- Get customer_id from email
    BEGIN
        SELECT customer_id INTO v_customer_id
        FROM customer
        WHERE email = p_customer_email;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Customer with email ' || p_customer_email || ' not found.');
    END;

    -- Check if employee exists (if employee_id is provided)
    IF p_employee_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_employee_exists
        FROM employee
        WHERE employee_id = p_employee_id;

        IF v_employee_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Employee with ID ' || p_employee_id || ' not found.');
        END IF;
    END IF;

    -- Get new order_id from sequence
    v_order_id := order_id_seq.NEXTVAL;

    -- Step 1: Insert into Orders
    INSERT INTO orders (order_id, customer_customer_id, order_date, total_amount, status)
    VALUES (v_order_id, v_customer_id, p_order_date, 0, 'Pending');

    -- Step 2: Process order details
    FOR i IN 1..p_order_details.COUNT LOOP
        -- Parse product_id and quantity
        BEGIN
            v_product_id := TO_NUMBER(SUBSTR(p_order_details(i), 1, INSTR(p_order_details(i), ',') - 1));
            v_quantity := TO_NUMBER(SUBSTR(p_order_details(i), INSTR(p_order_details(i), ',') + 1));
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20004, 'Invalid order detail format at index ' || i);
        END;

        -- Validate quantity
        IF v_quantity <= 0 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Invalid quantity for product ID: ' || v_product_id);
        END IF;

        -- Get price, stock and inventory info from product table
        BEGIN
            SELECT price, stock_quantity, inventory_inventory_id
            INTO v_price, v_available_stock, v_inventory_id
            FROM product
            WHERE product_id = v_product_id
            FOR UPDATE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20006, 'Product with ID ' || v_product_id || ' not found.');
        END;

        -- Check stock availability
        IF v_quantity > v_available_stock THEN
            RAISE_APPLICATION_ERROR(-20007, 'Insufficient stock for product ID: ' || v_product_id || '. Available: ' || v_available_stock || ', Requested: ' || v_quantity);
        END IF;

        -- Insert order detail
        INSERT INTO order_detail (order_detail_id, quantity, price_at_purchase, order_order_id, product_product_id)
        VALUES (order_detail_seq.NEXTVAL, v_quantity, v_price, v_order_id, v_product_id);

        -- Update product stock
        UPDATE product
        SET stock_quantity = stock_quantity - v_quantity
        WHERE product_id = v_product_id;

        -- Update inventory stock level
        UPDATE inventory
        SET stock_level = stock_level - v_quantity, last_updated = SYSDATE
        WHERE inventory_id = v_inventory_id;
    END LOOP;

    -- Calculate total amount with loyalty discount
    v_total_amount := calculate_total_amount(v_order_id, v_customer_id);

    -- Update order total and status
    UPDATE orders
    SET total_amount = v_total_amount, status = 'Completed'
    WHERE order_id = v_order_id;

    -- Add payment method
    INSERT INTO pay_method (payment_id, payment_type)
    VALUES (pay_method_seq.NEXTVAL, p_pay_type)
    RETURNING payment_id INTO v_pay_id;

    -- Create sales transaction
    INSERT INTO sales_transaction (tran_id, transaction_date, order_order_id, pay_method_payment_id, employee_employee_id)
    VALUES (sales_transaction_seq.NEXTVAL, SYSDATE, v_order_id, v_pay_id, p_employee_id);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Order added successfully. Order ID: ' || v_order_id);
EXCEPTION
    WHEN e_invalid_payment_type THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: Invalid payment type. Please select a valid payment method (Credit Card, Debit Card, Cash, or UPI).');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE insert_customer_with_loyalty (
    p_first_name IN customer.first_name%TYPE,
    p_last_name IN customer.last_name%TYPE,
    p_email IN customer.email%TYPE,
    p_phone IN customer.phone%TYPE,
    p_address IN customer.address%TYPE,
    p_join_loyalty IN BOOLEAN,
    p_loyalty_type IN VARCHAR2 DEFAULT NULL
) AS
    v_customer_id NUMBER;
    v_loyalty_id NUMBER;
    v_discount_percentage NUMBER;
    v_existing_count NUMBER;
BEGIN
    IF p_first_name IS NULL OR p_last_name IS NULL OR p_email IS NULL OR p_phone IS NULL OR p_address IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'All required fields must be provided');
    END IF;

    IF NOT REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$') THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid email format');
    END IF;

    IF NOT REGEXP_LIKE(p_phone, '^\d{10}$') THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid phone number format');
    END IF;

    SELECT COUNT(*) INTO v_existing_count
    FROM customer
    WHERE LOWER(email) = LOWER(p_email) OR phone = p_phone;

    IF v_existing_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Customer with this email or phone already exists');
    END IF;

    SELECT NVL(MAX(customer_id), 0) + 1 INTO v_customer_id FROM customer;

    IF p_join_loyalty THEN
        IF p_loyalty_type IS NULL THEN
            RAISE_APPLICATION_ERROR(-20005, 'Loyalty type must be provided when joining loyalty program');
        END IF;

        CASE UPPER(p_loyalty_type)
            WHEN 'GOLD' THEN v_discount_percentage := 20;
            WHEN 'SILVER' THEN v_discount_percentage := 10;
            ELSE RAISE_APPLICATION_ERROR(-20006, 'Invalid loyalty type. Must be GOLD or SILVER');
        END CASE;

        v_loyalty_id := loyalty_program_seq.NEXTVAL;

        INSERT INTO loyalty_program (loyalty_id, program_name, discount_percentage, start_date, end_date)
        VALUES (v_loyalty_id, UPPER(p_loyalty_type) || ' Member', v_discount_percentage, SYSDATE, ADD_MONTHS(SYSDATE, 12));
    END IF;

    INSERT INTO customer (customer_id, first_name, last_name, email, phone, address, loyalty_program_loyalty_id)
    VALUES (v_customer_id, p_first_name, p_last_name, p_email, p_phone, p_address, v_loyalty_id);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Customer inserted successfully. Customer ID: ' || v_customer_id);
    IF p_join_loyalty THEN
        DBMS_OUTPUT.PUT_LINE('Loyalty program joined. Loyalty ID: ' || v_loyalty_id);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

CREATE OR REPLACE PROCEDURE recommend_related_products(
    p_product_id IN NUMBER
) AS
    v_product_exists NUMBER;
BEGIN
    IF p_product_id IS NULL OR p_product_id <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid product ID');
    END IF;

    SELECT COUNT(*) INTO v_product_exists
    FROM product
    WHERE product_id = p_product_id;

    IF v_product_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Product with ID ' || p_product_id || ' does not exist');
    END IF;

    FOR r IN (
        SELECT DISTINCT p.product_name, p.price
        FROM product p
        JOIN order_detail od ON p.product_id = od.product_product_id
        WHERE od.order_order_id IN (
            SELECT order_order_id
            FROM order_detail
            WHERE product_product_id = p_product_id
        )
        AND p.product_id != p_product_id
        FETCH FIRST 5 ROWS ONLY
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Recommended Product: ' || r.product_name || ', Price: ' || r.price);
    END LOOP;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No related products found.');
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE update_order_status(
    p_order_id IN NUMBER,
    p_new_status IN VARCHAR2
) AS
    v_order_exists NUMBER;
BEGIN
    IF p_order_id IS NULL OR p_new_status IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Order ID and new status must be provided');
    END IF;

    SELECT COUNT(*) INTO v_order_exists
    FROM orders
    WHERE order_id = p_order_id;

    IF v_order_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Order with ID ' || p_order_id || ' does not exist');
    END IF;

    IF UPPER(p_new_status) NOT IN ('PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED') THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid order status: ' || p_new_status);
    END IF;

    UPDATE orders
    SET status = UPPER(p_new_status)
    WHERE order_id = p_order_id;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Order status updated successfully');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

CREATE OR REPLACE PROCEDURE generate_sales_report(
    p_start_date IN DATE,
    p_end_date IN DATE
) AS
    v_total_sales NUMBER := 0;
    v_total_discounts NUMBER := 0;
BEGIN
    IF p_start_date IS NULL OR p_end_date IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Start date and end date must be provided');
    END IF;

    IF p_start_date > p_end_date THEN
        RAISE_APPLICATION_ERROR(-20002, 'Start date must be before or equal to end date');
    END IF;

    SELECT NVL(SUM(quantity * price_at_purchase), 0)
    INTO v_total_sales
    FROM order_detail od
    JOIN orders o ON od.order_order_id = o.order_id
    WHERE o.order_date BETWEEN p_start_date AND p_end_date;

    SELECT NVL(SUM(o.total_amount * NVL(lp.discount_percentage, 0) / 100), 0)
    INTO v_total_discounts
    FROM orders o
    JOIN customer c ON o.customer_customer_id = c.customer_id
    LEFT JOIN loyalty_program lp ON c.loyalty_program_loyalty_id = lp.loyalty_id
    WHERE o.order_date BETWEEN p_start_date AND p_end_date;

    DBMS_OUTPUT.PUT_LINE('Sales Report from ' || TO_CHAR(p_start_date, 'YYYY-MM-DD') || ' to ' || TO_CHAR(p_end_date, 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Total Sales: $' || TO_CHAR(v_total_sales, '999,999,999.99'));
    DBMS_OUTPUT.PUT_LINE('Total Discounts: $' || TO_CHAR(v_total_discounts, '999,999,999.99'));
    DBMS_OUTPUT.PUT_LINE('Net Sales: $' || TO_CHAR(v_total_sales - v_total_discounts, '999,999,999.99'));

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE update_reorder_request(
    p_reorder_request_id IN NUMBER,
    p_quantity_requested IN NUMBER,
    p_request_date IN DATE,
    p_expected_delivery_date IN DATE,
    p_actual_delivery_date IN DATE DEFAULT NULL,
    p_status IN VARCHAR2,
    p_supplier_id IN NUMBER,
    p_INVENTORY_ID IN NUMBER
) AS
    v_reorder_exists NUMBER;
    v_supplier_exists NUMBER;
    v_inventory_exists NUMBER;
BEGIN
    -- Check for NULL values in required fields
    IF p_reorder_request_id IS NULL OR p_quantity_requested IS NULL OR p_request_date IS NULL OR
       p_expected_delivery_date IS NULL OR p_status IS NULL OR p_supplier_id IS NULL OR p_INVENTORY_ID IS NULL THEN
        RAISE_APPLICATION_ERROR(-20023, 'Error: All required fields must be provided.');
    END IF;

    -- Validate positive numbers
    IF p_reorder_request_id <= 0 THEN
        RAISE_APPLICATION_ERROR(-20020, 'Error: Reorder Request ID must be a positive number.');
    END IF;
    IF p_quantity_requested <= 0 THEN
        RAISE_APPLICATION_ERROR(-20021, 'Error: Quantity Requested must be a positive number.');
    END IF;
    IF p_supplier_id <= 0 THEN
        RAISE_APPLICATION_ERROR(-20022, 'Error: Supplier ID must be a positive number.');
    END IF;
    IF p_INVENTORY_ID <= 0 THEN
        RAISE_APPLICATION_ERROR(-20024, 'Error: INVENTORY ID must be a positive number.');
    END IF;

    -- Check if reorder request exists
    SELECT COUNT(*) INTO v_reorder_exists FROM reorder_request WHERE reorder_request_id = p_reorder_request_id;
    IF v_reorder_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20025, 'Error: Reorder Request with ID ' || p_reorder_request_id || ' not found.');
    END IF;

    -- Check if supplier exists
    SELECT COUNT(*) INTO v_supplier_exists FROM supplier WHERE supplier_id = p_supplier_id;
    IF v_supplier_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20026, 'Error: Supplier with ID ' || p_supplier_id || ' not found.');
    END IF;

    -- Check if inventory exists
    SELECT COUNT(*) INTO v_inventory_exists FROM inventory WHERE inventory_id = p_INVENTORY_ID;
    IF v_inventory_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20027, 'Error: Inventory with ID ' || p_INVENTORY_ID || ' not found.');
    END IF;

    -- Perform the update
    UPDATE reorder_request
    SET quantity_requested = p_quantity_requested,
        request_date = p_request_date,
        expected_delivery_date = p_expected_delivery_date,
        actual_delivery_date = p_actual_delivery_date,
        status = p_status,
        supplier_supplier_id = p_supplier_id,
        INVENTORY_INVENTORY_ID = p_INVENTORY_ID
    WHERE reorder_request_id = p_reorder_request_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20028, 'Error: Update failed. No rows affected.');
    END IF;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END update_reorder_request;
/

CREATE OR REPLACE PROCEDURE update_product_and_inventory_stock(
    p_reorder_request_id IN NUMBER
) AS
    v_product_id NUMBER;
    v_quantity NUMBER;
    v_inventory_id NUMBER;
BEGIN
    -- Fetch product ID, quantity, and inventory ID from the reorder request
    SELECT product_product_id, quantity_requested, inventory_inventory_id INTO v_product_id, v_quantity, v_inventory_id
    FROM reorder_request
    WHERE reorder_request_id = p_reorder_request_id;
    -- Update the stock quantity of the product
    UPDATE product
    SET stock_quantity = stock_quantity + v_quantity
    WHERE product_id = v_product_id;
    -- Update the stock level of the inventory
    UPDATE inventory
    SET stock_level = stock_level + v_quantity,
        last_updated = SYSDATE
    WHERE inventory_id = v_inventory_id;
    COMMIT; -- Commit the transaction
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Reorder request with ID ' || p_reorder_request_id || ' not found.');
    WHEN OTHERS THEN
        ROLLBACK; -- Rollback in case of any error
        RAISE; -- Re-raise the exception for debugging/logging purposes
END update_product_and_inventory_stock;
/


CREATE OR REPLACE PROCEDURE update_reorder_status(
    p_reorder_request_id IN NUMBER,
    p_status IN VARCHAR2,
    p_actual_delivery_date IN DATE
) AS
    v_request_exists NUMBER;
    v_current_status VARCHAR2(50);
BEGIN
    -- Validate inputs
    IF p_reorder_request_id <= 0 THEN
        RAISE_APPLICATION_ERROR(-20030, 'Error: Reorder Request ID must be a positive number.');
    END IF;
    
    IF p_status IS NULL THEN
        RAISE_APPLICATION_ERROR(-20031, 'Error: Status cannot be null.');
    END IF;

    -- Check if the reorder request exists
    SELECT COUNT(*), MAX(status)
    INTO v_request_exists, v_current_status
    FROM reorder_request
    WHERE reorder_request_id = p_reorder_request_id;

    IF v_request_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20032, 'Error: Reorder request with ID ' || p_reorder_request_id || ' does not exist.');
    END IF;

    -- If the current status is already 'DELIVERED', prevent further updates
    IF UPPER(v_current_status) = 'DELIVERED' THEN
        RAISE_APPLICATION_ERROR(-20033, 'Error: This reorder request has already been delivered and cannot be updated.');
    END IF;

    -- Update the reorder request with the new status and actual delivery date
    UPDATE reorder_request
    SET status = p_status,
        actual_delivery_date = p_actual_delivery_date
    WHERE reorder_request_id = p_reorder_request_id;

    -- If status is being set to 'DELIVERED', update product and inventory stock
    IF UPPER(p_status) = 'DELIVERED' THEN
        update_product_and_inventory_stock(p_reorder_request_id);
        DBMS_OUTPUT.PUT_LINE('Reorder request completed. Product and inventory tables updated.');
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Reorder request status updated successfully.');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END update_reorder_status;
/

CREATE OR REPLACE PROCEDURE update_customer(
    p_customer_id IN customer.customer_id%TYPE,
    p_first_name IN customer.first_name%TYPE DEFAULT NULL,
    p_last_name IN customer.last_name%TYPE DEFAULT NULL,
    p_email IN customer.email%TYPE DEFAULT NULL,
    p_phone IN customer.phone%TYPE DEFAULT NULL,
    p_address IN customer.address%TYPE DEFAULT NULL,
    p_loyalty_program_id IN loyalty_program.loyalty_id%TYPE DEFAULT NULL
) AS
    v_customer customer%ROWTYPE;
    v_changes VARCHAR2(4000) := '';
    v_update_needed BOOLEAN := FALSE;

    FUNCTION is_valid_email(p_email VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        RETURN REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');
    END;

    FUNCTION is_valid_phone(p_phone VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        RETURN REGEXP_LIKE(p_phone, '^\d{10}$');
    END;

BEGIN
    -- Check if customer exists
    BEGIN
        SELECT * INTO v_customer
        FROM customer
        WHERE customer_id = p_customer_id
        FOR UPDATE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Customer with ID ' || p_customer_id || ' does not exist.');
    END;

    -- Update first name if provided
    IF p_first_name IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Please enter a valid value for first name.');
    ELSIF p_first_name != v_customer.first_name THEN
        v_customer.first_name := p_first_name;
        v_changes := v_changes || 'First name updated to ' || p_first_name || '. ';
        v_update_needed := TRUE;
    END IF;

    -- Update last name if provided
    IF p_last_name IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Please enter a valid value for last name.');
    ELSIF p_last_name != v_customer.last_name THEN
        v_customer.last_name := p_last_name;
        v_changes := v_changes || 'Last name updated to ' || p_last_name || '. ';
        v_update_needed := TRUE;
    END IF;

    -- Update email if provided and valid
    IF p_email IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Please enter a valid value for email.');
    ELSIF NOT is_valid_email(p_email) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid email format.');
    ELSIF p_email != v_customer.email THEN
        v_customer.email := p_email;
        v_changes := v_changes || 'Email updated to ' || p_email || '. ';
        v_update_needed := TRUE;
    END IF;

    -- Update phone if provided and valid
    IF p_phone IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Please enter a valid value for phone.');
    ELSIF NOT is_valid_phone(p_phone) THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid phone format. Please use 10 digits.');
    ELSIF p_phone != v_customer.phone THEN
        v_customer.phone := p_phone;
        v_changes := v_changes || 'Phone updated to ' || p_phone || '. ';
        v_update_needed := TRUE;
    END IF;

    -- Update address if provided
    IF p_address IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Please enter a valid value for address.');
    ELSIF p_address != v_customer.address THEN
        v_customer.address := p_address;
        v_changes := v_changes || 'Address updated. ';
        v_update_needed := TRUE;
    END IF;

    -- Update loyalty program if provided
    IF p_loyalty_program_id IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Please enter a valid value for loyalty program ID.');
    ELSIF p_loyalty_program_id < 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Invalid loyalty program ID. Must be a positive number.');
    ELSIF p_loyalty_program_id != v_customer.loyalty_program_loyalty_id THEN
        -- Check if loyalty program exists
        DECLARE
            v_loyalty_exists NUMBER;
        BEGIN
            SELECT COUNT(*) INTO v_loyalty_exists
            FROM loyalty_program
            WHERE loyalty_id = p_loyalty_program_id;
            
            IF v_loyalty_exists = 0 THEN
                RAISE_APPLICATION_ERROR(-20005, 'Loyalty program with ID ' || p_loyalty_program_id || ' does not exist.');
            END IF;
        END;
        
        v_customer.loyalty_program_loyalty_id := p_loyalty_program_id;
        v_changes := v_changes || 'Loyalty program updated to ID ' || p_loyalty_program_id || '. ';
        v_update_needed := TRUE;
    END IF;

    -- Perform the update only if changes were made
    IF v_update_needed THEN
        UPDATE customer
        SET ROW = v_customer
        WHERE customer_id = p_customer_id;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Customer updated successfully. ' || v_changes);
    ELSE
        DBMS_OUTPUT.PUT_LINE('No changes were made to the customer.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END update_customer;
/


CREATE OR REPLACE PROCEDURE delete_order(
    p_order_id IN NUMBER
) AS
    v_product_id NUMBER;
    v_quantity NUMBER;
    v_inventory_id NUMBER;
    v_payment_id NUMBER;
    v_order_exists NUMBER;
BEGIN
    -- Validate that the order exists
    SELECT COUNT(1) 
    INTO v_order_exists
    FROM orders 
    WHERE order_id = p_order_id;
 
    IF v_order_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: Order with ID ' || p_order_id || ' does not exist.');
    END IF;
 
    -- Step 1: Retrieve payment method ID before deleting sales transaction
    BEGIN
        SELECT pay_method_payment_id INTO v_payment_id 
        FROM sales_transaction 
        WHERE order_order_id = p_order_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_payment_id := NULL;
    END;

    -- Step 2: Process each product in the order details to restore stock and inventory levels
    FOR product_rec IN (
        SELECT od.product_product_id AS product_id,
               od.quantity AS quantity,
               p.inventory_inventory_id AS inventory_id
        FROM order_detail od
        JOIN product p ON od.product_product_id = p.product_id
        WHERE od.order_order_id = p_order_id
    ) LOOP
        UPDATE product
        SET stock_quantity = stock_quantity + product_rec.quantity
        WHERE product_id = product_rec.product_id;
 
        UPDATE inventory
        SET stock_level = stock_level + product_rec.quantity,
            last_updated = SYSDATE
        WHERE inventory_id = product_rec.inventory_id;
    END LOOP;
 
    -- Step 3: Delete from order_detail table
    DELETE FROM order_detail WHERE order_order_id = p_order_id;
 
    -- Step 4: Delete from sales_transaction table
    DELETE FROM sales_transaction WHERE order_order_id = p_order_id;
 
    -- Step 5: Remove payment method if found
    IF v_payment_id IS NOT NULL THEN
        DELETE FROM pay_method WHERE payment_id = v_payment_id;
        DBMS_OUTPUT.PUT_LINE('Payment method with ID ' || v_payment_id || ' deleted.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('No payment method found for Order ID ' || p_order_id);
    END IF;
 
    -- Step 6: Delete the order itself
    DELETE FROM orders WHERE order_id = p_order_id;
 
    COMMIT;
 
    DBMS_OUTPUT.PUT_LINE('Order with ID ' || p_order_id || ' deleted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
        ROLLBACK;
END delete_order;
/