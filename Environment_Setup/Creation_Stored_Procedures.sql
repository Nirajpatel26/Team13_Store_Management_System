SET SERVEROUTPUT ON;
-- Drop existing procedures
BEGIN
    FOR proc_rec IN (SELECT object_name FROM user_objects WHERE object_type = 'PROCEDURE' AND object_name LIKE 'INSERT_%') LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP PROCEDURE ' || proc_rec.object_name;
            DBMS_OUTPUT.PUT_LINE('Dropped procedure: ' || proc_rec.object_name);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Could not drop procedure ' || proc_rec.object_name || ': ' || SQLERRM);
        END;
    END LOOP;
END;
/
-- Customer
CREATE OR REPLACE PROCEDURE INSERT_CUSTOMER(
    p_customer_id IN customer.customer_id%TYPE,
    p_first_name IN customer.first_name%TYPE,
    p_last_name IN customer.last_name%TYPE,
    p_email IN customer.email%TYPE,
    p_phone IN customer.phone%TYPE,
    p_address IN customer.address%TYPE,
    p_loyalty_program_id IN loyalty_program.loyalty_id%TYPE DEFAULT NULL
) AS
BEGIN
    INSERT INTO customer (customer_id, first_name, last_name, email, phone, address, loyalty_program_loyalty_id)
    VALUES (p_customer_id, p_first_name, p_last_name, p_email, p_phone, p_address, p_loyalty_program_id);
    COMMIT;
END;
/
-- Product
CREATE OR REPLACE PROCEDURE INSERT_PRODUCT(
    p_product_id IN product.product_id%TYPE,
    p_product_name IN product.product_name%TYPE,
    p_description IN product.description%TYPE,
    p_price IN product.price%TYPE,
    p_stock_quantity IN product.stock_quantity%TYPE,
    p_reorder_level IN product.reorder_level%TYPE,
    p_supplier_id IN supplier.supplier_id%TYPE DEFAULT NULL,
    p_category_id IN category.category_id%TYPE DEFAULT NULL,
    p_inventory_id IN inventory.inventory_id%TYPE
) AS
BEGIN
    INSERT INTO product (product_id, product_name, description, price, stock_quantity, reorder_level, supplier_supplier_id, category_category_id, inventory_inventory_id)
    VALUES (p_product_id, p_product_name, p_description, p_price, p_stock_quantity, p_reorder_level, p_supplier_id, p_category_id, p_inventory_id);
    COMMIT;
END;
/
-- Order
CREATE OR REPLACE PROCEDURE INSERT_ORDER(
    p_order_id IN orders.order_id%TYPE,
    p_order_date IN orders.order_date%TYPE,
    p_total_amount IN orders.total_amount%TYPE,
    p_status IN orders.status%TYPE DEFAULT 'Pending',
    p_customer_id IN customer.customer_id%TYPE
) AS
BEGIN
    INSERT INTO orders (order_id, order_date, total_amount, status, customer_customer_id)
    VALUES (p_order_id, p_order_date, p_total_amount, p_status, p_customer_id);
    COMMIT;
END;
/
-- Sales Transaction
CREATE OR REPLACE PROCEDURE INSERT_SALES_TRANSACTION(
    p_tran_id IN sales_transaction.tran_id%TYPE,
    p_transaction_date IN sales_transaction.transaction_date%TYPE,
    p_order_id IN orders.order_id%TYPE DEFAULT NULL,
    p_payment_id IN pay_method.payment_id%TYPE,
    p_employee_id IN employee.employee_id%TYPE DEFAULT NULL
) AS
BEGIN
    INSERT INTO sales_transaction (tran_id, transaction_date, order_order_id, pay_method_payment_id, employee_employee_id)
    VALUES (p_tran_id, p_transaction_date, p_order_id, p_payment_id, p_employee_id);
    COMMIT;
END;
/
-- Order Detail
CREATE OR REPLACE PROCEDURE INSERT_ORDER_DETAIL(
    p_order_detail_id IN order_detail.order_detail_id%TYPE,
    p_quantity IN order_detail.quantity%TYPE,
    p_price_at_purchase IN order_detail.price_at_purchase%TYPE,
    p_order_id IN orders.order_id%TYPE,
    p_product_id IN product.product_id%TYPE
) AS
BEGIN
    INSERT INTO order_detail (order_detail_id, quantity, price_at_purchase, order_order_id, product_product_id)
    VALUES (p_order_detail_id, p_quantity, p_price_at_purchase, p_order_id, p_product_id);
    COMMIT;
END;
/
-- Payment Method
CREATE OR REPLACE PROCEDURE INSERT_PAYMENT_METHOD(
    p_payment_id IN pay_method.payment_id%TYPE,
    p_payment_type IN pay_method.payment_type%TYPE
) AS
BEGIN
    INSERT INTO pay_method (payment_id, payment_type)
    VALUES (p_payment_id, p_payment_type);
    COMMIT;
END;
/
-- Inventory
CREATE OR REPLACE PROCEDURE INSERT_INVENTORY(
    p_inventory_id IN inventory.inventory_id%TYPE,
    p_stock_level IN inventory.stock_level%TYPE,
    p_last_updated IN inventory.last_updated%TYPE
) AS
BEGIN
    INSERT INTO inventory (inventory_id, stock_level, last_updated)
    VALUES (p_inventory_id, p_stock_level, p_last_updated);
    COMMIT;
END;
/
-- Supplier
CREATE OR REPLACE PROCEDURE INSERT_SUPPLIER(
    p_supplier_id IN supplier.supplier_id%TYPE,
    p_supplier_name IN supplier.supplier_name%TYPE,
    p_contact_name IN supplier.contact_name%TYPE,
    p_phone IN supplier.phone%TYPE,
    p_email IN supplier.email%TYPE,
    p_address IN supplier.address%TYPE
) AS
BEGIN
    INSERT INTO supplier (supplier_id, supplier_name, contact_name, phone, email, address)
    VALUES (p_supplier_id, p_supplier_name, p_contact_name, p_phone, p_email, p_address);
    COMMIT;
END;
/
-- Category
CREATE OR REPLACE PROCEDURE INSERT_CATEGORY(
    p_category_id IN category.category_id%TYPE,
    p_category_name IN category.category_name%TYPE,
    p_description IN category.description%TYPE
) AS
BEGIN
    INSERT INTO category (category_id, category_name, description)
    VALUES (p_category_id, p_category_name, p_description);
    COMMIT;
END;
/
-- Loyalty Program
CREATE OR REPLACE PROCEDURE INSERT_LOYALTY_PROGRAM(
    p_loyalty_id IN loyalty_program.loyalty_id%TYPE,
    p_program_name IN loyalty_program.program_name%TYPE,
    p_discount_percentage IN loyalty_program.discount_percentage%TYPE,
    p_start_date IN loyalty_program.start_date%TYPE,
    p_end_date IN loyalty_program.end_date%TYPE
) AS
BEGIN
    INSERT INTO loyalty_program (loyalty_id, program_name, discount_percentage, start_date, end_date)
    VALUES (p_loyalty_id, p_program_name, p_discount_percentage, p_start_date, p_end_date);
    COMMIT;
END;
/
-- Marketing
CREATE OR REPLACE PROCEDURE INSERT_MARKETING(
    p_marketing_id IN marketing.marketing_id%TYPE,
    p_message IN marketing.message%TYPE,
    p_sent_via IN marketing.sent_via%TYPE,
    p_date_sent IN marketing.date_sent%TYPE,
    p_discount_offered IN marketing.discount_offered%TYPE,
    p_customer_id IN customer.customer_id%TYPE
) AS
BEGIN
    INSERT INTO marketing (marketing_id, message, sent_via, date_sent, discount_offered,customer_customer_id)
    VALUES (p_marketing_id, p_message, p_sent_via, p_date_sent, p_discount_offered,p_customer_id);
    COMMIT;
END;
/
-- Employee
CREATE OR REPLACE PROCEDURE INSERT_EMPLOYEE(
    p_employee_id IN employee.employee_id%TYPE,
    p_first_name IN employee.first_name%TYPE,
    p_last_name IN employee.last_name%TYPE,
    p_email IN employee.email%TYPE,
    p_phone IN employee.phone%TYPE,
    p_address IN employee.address%TYPE,
    p_position IN employee.position%TYPE,
    p_hire_date IN employee.hire_date%TYPE,
    p_salary IN employee.salary%TYPE
) AS
BEGIN
    INSERT INTO employee (employee_id, first_name, last_name, email, phone, address, position, hire_date, salary)
    VALUES (p_employee_id, p_first_name, p_last_name, p_email, p_phone, p_address, p_position, p_hire_date, p_salary);
    COMMIT;
END;
/
-- Reorder Request
CREATE OR REPLACE PROCEDURE INSERT_REORDER_REQUEST(
    p_reorder_request_id IN reorder_request.reorder_request_id%TYPE,
    p_quantity_requested IN reorder_request.quantity_requested%TYPE,
    p_request_date IN reorder_request.request_date%TYPE,
    p_expected_delivery_date IN reorder_request.expected_delivery_date%TYPE,
    p_actual_delivery_date IN reorder_request.actual_delivery_date%TYPE,
    p_status IN reorder_request.status%TYPE,
    p_product_id IN product.product_id%TYPE,
    p_supplier_id IN supplier.supplier_id%TYPE,
    p_inventory_id IN inventory.inventory_id%TYPE
) AS
BEGIN
    INSERT INTO reorder_request (reorder_request_id, quantity_requested, request_date, expected_delivery_date, actual_delivery_date, status, product_product_id, supplier_supplier_id, inventory_inventory_id)
    VALUES (p_reorder_request_id, p_quantity_requested, p_request_date, p_expected_delivery_date, p_actual_delivery_date, p_status, p_product_id, p_supplier_id, p_inventory_id);
    COMMIT;
END;
/