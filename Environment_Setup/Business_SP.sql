SET SERVEROUTPUT ON;

BEGIN
    FOR obj IN (SELECT object_name, object_type FROM user_objects WHERE object_type IN ('PROCEDURE') AND object_name IN (
        'ADD_ORDER','INSERT_CUSTOMER_WITH_LOYALTY','RECOMMEND_RELATED_PRODUCTS', 'UPDATE_ORDER_STATUS', 'GENERATE_SALES_REPORT',
        'UPDATE_REORDER_REQUEST', 'UPDATE_REORDER_STATUS','UPDATE_CUSTOMER'
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
BEGIN
    -- Get customer_id from email
    SELECT customer_id INTO v_customer_id
    FROM customer
    WHERE email = p_customer_email;

    -- Get new order_id from sequence
    v_order_id := order_id_seq.NEXTVAL;

    -- Step 1: Insert into Orders
    INSERT INTO orders (
        order_id,
        customer_customer_id,
        order_date,
        total_amount,
        status
    )
    VALUES (
        v_order_id,
        v_customer_id,
        p_order_date,
        0,
        'Pending'
    );

    -- Step 2: Process order details
    FOR i IN 1..p_order_details.COUNT LOOP
        -- Parse product_id and quantity
        v_product_id := TO_NUMBER(SUBSTR(p_order_details(i), 1, INSTR(p_order_details(i), ',') - 1));
        v_quantity := TO_NUMBER(SUBSTR(p_order_details(i), INSTR(p_order_details(i), ',') + 1));

        -- Get price, stock and inventory info from product table
        SELECT price, stock_quantity, inventory_inventory_id
        INTO v_price, v_available_stock, v_inventory_id
        FROM product
        WHERE product_id = v_product_id
        FOR UPDATE;

        -- Check stock availability
        IF v_quantity > v_available_stock THEN
            RAISE_APPLICATION_ERROR(-20001,
                'Insufficient stock for product ID: ' || v_product_id ||
                '. Available: ' || v_available_stock ||
                ', Requested: ' || v_quantity);
        END IF;

        -- Insert order detail
        INSERT INTO order_detail (
            order_detail_id,
            quantity,
            price_at_purchase,
            order_order_id,
            product_product_id
        )
        VALUES (
            order_detail_seq.NEXTVAL,
            v_quantity,
            v_price,
            v_order_id,
            v_product_id
        );

        -- Update product stock
        UPDATE product
        SET stock_quantity = stock_quantity - v_quantity
        WHERE product_id = v_product_id;

        -- Update inventory stock level
        UPDATE inventory
        SET stock_level = stock_level - v_quantity,
            last_updated = SYSDATE
        WHERE inventory_id = v_inventory_id;
    END LOOP;

    -- Calculate total amount with loyalty discount
    v_total_amount := calculate_total_amount(v_order_id, v_customer_id);

    -- Update order total and status
    UPDATE orders
    SET total_amount = v_total_amount,
        status = 'Completed'
    WHERE order_id = v_order_id;

    -- Add payment method
    INSERT INTO pay_method (
        payment_id,
        payment_type
    )
    VALUES (
        pay_method_seq.NEXTVAL,
        p_pay_type
    )
    RETURNING payment_id INTO v_pay_id;

    -- Create sales transaction
    INSERT INTO sales_transaction (
        tran_id,
        transaction_date,
        order_order_id,
        pay_method_payment_id,
        employee_employee_id
    )
    VALUES (
        sales_transaction_seq.NEXTVAL,
        SYSDATE,
        v_order_id,
        v_pay_id,
        p_employee_id
    );

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Customer with email ' || p_customer_email || ' not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
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
    -- Check if customer already exists
    SELECT COUNT(*)
    INTO v_existing_count
    FROM customer
    WHERE first_name = p_first_name
    AND (email = p_email OR phone = p_phone);

    IF v_existing_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Customer with this name, email, or phone already exists.');
    END IF;

    -- Generate new customer ID
    SELECT NVL(MAX(customer_id), 0) + 1
    INTO v_customer_id
    FROM customer;

    -- Handle loyalty program
    IF p_join_loyalty THEN
        -- Determine discount percentage
        IF UPPER(p_loyalty_type) = 'GOLD' THEN
            v_discount_percentage := 20;
        ELSIF UPPER(p_loyalty_type) = 'SILVER' THEN
            v_discount_percentage := 10;
        ELSE
            RAISE_APPLICATION_ERROR(-20002, 'Invalid loyalty type. Must be GOLD or SILVER.');
        END IF;

        -- Generate new loyalty ID using the sequence
        v_loyalty_id := loyalty_program_seq.NEXTVAL;

        -- Insert into loyalty_program
        INSERT INTO loyalty_program (
            loyalty_id,
            program_name,
            discount_percentage,
            start_date,
            end_date
        ) VALUES (
            v_loyalty_id,
            p_loyalty_type || ' Member',
            v_discount_percentage,
            SYSDATE,
            ADD_MONTHS(SYSDATE, 12)
        );
    END IF;

    -- Insert customer
    INSERT INTO customer (
        customer_id,
        first_name,
        last_name,
        email,
        phone,
        address,
        loyalty_program_loyalty_id
    ) VALUES (
        v_customer_id,
        p_first_name,
        p_last_name,
        p_email,
        p_phone,
        p_address,
        v_loyalty_id
    );

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
BEGIN
    -- Loop through recommended products (cursor is implicit in the FOR loop)
    FOR r IN (
        SELECT p.product_name, p.price
        FROM product p
        JOIN order_detail od ON p.product_id = od.product_product_id
        WHERE od.order_order_id IN (
            SELECT order_order_id
            FROM order_detail
            WHERE product_product_id = p_product_id
        )
        AND p.product_id != p_product_id  -- Exclude the original product
    ) LOOP
        -- Output the recommended products
        DBMS_OUTPUT.PUT_LINE('Recommended Product: ' || r.product_name || ', Price: ' || r.price);
    END LOOP;

    -- If no recommendations were found, output a message (this is now managed automatically)
    -- No need for a separate check for NOTFOUND because the FOR loop handles that internally.
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No related products found.');
    END IF;
END;
/




CREATE OR REPLACE PROCEDURE update_order_status(
    p_order_id IN NUMBER,
    p_new_status IN VARCHAR2
) AS
BEGIN
    -- Update the order status
    UPDATE orders
    SET status = p_new_status
    WHERE order_id = p_order_id;
    COMMIT;
END;
/



CREATE OR REPLACE PROCEDURE generate_sales_report(
    p_start_date IN DATE,
    p_end_date IN DATE
) AS
    v_total_sales NUMBER := 0;
    v_total_discounts NUMBER := 0;
    v_discount_percentage NUMBER := 0;
BEGIN
    -- Calculate total sales
    SELECT SUM(quantity * price_at_purchase) INTO v_total_sales
    FROM order_detail od
    JOIN orders o ON od.order_order_id = o.order_id
    WHERE o.order_date BETWEEN p_start_date AND p_end_date;

    -- Calculate total discounts applied, assuming the discount is linked via the loyalty_program table
    SELECT SUM(o.total_amount * (1 - (1 - lp.discount_percentage / 100))) INTO v_total_discounts
    FROM orders o
    JOIN customer c ON o.customer_customer_id = c.customer_id
    LEFT JOIN loyalty_program lp ON c.loyalty_program_loyalty_id = lp.loyalty_id
    WHERE o.order_date BETWEEN p_start_date AND p_end_date
    AND lp.discount_percentage IS NOT NULL;  -- Ensures that the discount is applied if available

    -- Output the results
    DBMS_OUTPUT.PUT_LINE('Total Sales: ' || v_total_sales);
    DBMS_OUTPUT.PUT_LINE('Total Discounts: ' || v_total_discounts);
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
BEGIN
    -- Error handling for negative or invalid inputs
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
        RAISE_APPLICATION_ERROR(-20022, 'Error: INVENTORY ID must be a positive number.');
    END IF;

    -- Update the reorder request with provided details
    UPDATE reorder_request
    SET quantity_requested = p_quantity_requested,
        request_date = p_request_date,
        expected_delivery_date = p_expected_delivery_date,
        actual_delivery_date = p_actual_delivery_date,
        status = p_status,
        supplier_supplier_id = p_supplier_id,
        INVENTORY_INVENTORY_ID =p_INVENTORY_ID
    WHERE reorder_request_id = p_reorder_request_id;

    COMMIT; -- Commit the changes to the database

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Reorder Request with ID ' || p_reorder_request_id || ' not found.');
        ROLLBACK;
    WHEN OTHERS THEN
        ROLLBACK; -- Rollback in case of any error
        RAISE; -- Re-raise the exception for debugging/logging purposes
END update_reorder_request;
/


CREATE OR REPLACE PROCEDURE update_reorder_status(
    p_reorder_request_id IN NUMBER,
    p_status IN VARCHAR2,
    p_actual_delivery_date IN DATE
) AS
BEGIN
    -- Validate inputs
    IF p_reorder_request_id <= 0 THEN
        RAISE_APPLICATION_ERROR(-20030, 'Error: Reorder Request ID must be a positive number.');
    END IF;

    IF p_status IS NULL THEN
        RAISE_APPLICATION_ERROR(-20031, 'Error: Status cannot be null.');
    END IF;

    -- Update the reorder request with the new status and actual delivery date
    UPDATE reorder_request
    SET status = p_status,
        actual_delivery_date = p_actual_delivery_date
    WHERE reorder_request_id = p_reorder_request_id;

    -- Check if any row was updated
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20032, 'Error: No reorder request found with the given ID.');
    END IF;

    COMMIT; -- Commit the changes to the database

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- Rollback in case of any error
        RAISE; -- Re-raise the exception for debugging/logging purposes
END update_reorder_status;
/
CREATE OR REPLACE PROCEDURE update_customer(
    p_customer_id IN customer.customer_id%TYPE,
    p_first_name IN customer.first_name%TYPE,
    p_last_name IN customer.last_name%TYPE,
    p_email IN customer.email%TYPE,
    p_phone IN customer.phone%TYPE,
    p_address IN customer.address%TYPE,
    p_loyalty_program_id IN loyalty_program.loyalty_id%TYPE DEFAULT NULL
) AS
BEGIN
    -- Validate that the customer exists
    DECLARE
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM customer
        WHERE customer_id = p_customer_id;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Customer with ID ' || p_customer_id || ' does not exist.');
        END IF;
    END;

    -- Update the customer's details
    UPDATE customer
    SET first_name = p_first_name,
        last_name = p_last_name,
        email = p_email,
        phone = p_phone,
        address = p_address,
        loyalty_program_loyalty_id = p_loyalty_program_id
    WHERE customer_id = p_customer_id;

    COMMIT; -- Commit the transaction

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- Rollback in case of any error
        RAISE; -- Re-raise the exception for debugging/logging purposes
END update_customer;
/



