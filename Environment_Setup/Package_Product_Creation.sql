
CREATE OR REPLACE PACKAGE pkg_inventory_management IS
    PROCEDURE insert_product(
        p_product_id IN NUMBER,
        p_product_name IN VARCHAR2,
        p_description IN VARCHAR2,
        p_price IN NUMBER,
        p_stock_quantity IN NUMBER,
        p_reorder_level IN NUMBER,
        p_supplier_id IN NUMBER,
        p_category_id IN NUMBER,
        p_inventory_id IN NUMBER
    );

    PROCEDURE update_product_stock(
        p_product_id IN NUMBER,
        p_new_quantity IN NUMBER
    );

    PROCEDURE update_product_price(
        p_product_id IN NUMBER,
        p_new_price IN NUMBER
    );

    PROCEDURE check_low_stock(
        p_product_id IN NUMBER
    );
END pkg_inventory_management;
/

CREATE OR REPLACE PACKAGE BODY pkg_inventory_management IS

    -- Helper function to check if an ID exists in a table
    FUNCTION id_exists(p_id IN NUMBER, p_table_name IN VARCHAR2, p_column_name IN VARCHAR2) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || p_table_name || ' WHERE ' || p_column_name || ' = :1'
        INTO v_count
        USING p_id;
        
        RETURN v_count > 0;
    END id_exists;

    -- Procedure to insert a new product
    PROCEDURE insert_product(
        p_product_id IN NUMBER,
        p_product_name IN VARCHAR2,
        p_description IN VARCHAR2,
        p_price IN NUMBER,
        p_stock_quantity IN NUMBER,
        p_reorder_level IN NUMBER,
        p_supplier_id IN NUMBER,
        p_category_id IN NUMBER,
        p_inventory_id IN NUMBER
    ) IS
        v_error_message VARCHAR2(4000) := '';
    BEGIN
        -- Check for null or empty values
        IF p_product_id IS NULL THEN
            v_error_message := v_error_message || 'Product ID must be provided. ';
        END IF;
        IF p_product_name IS NULL OR TRIM(p_product_name) = '' THEN
            v_error_message := v_error_message || 'Product name must be provided. ';
        END IF;
        IF p_price IS NULL THEN
            v_error_message := v_error_message || 'Price must be provided. ';
        END IF;
        IF p_stock_quantity IS NULL THEN
            v_error_message := v_error_message || 'Stock quantity must be provided. ';
        END IF;
        IF p_reorder_level IS NULL THEN
            v_error_message := v_error_message || 'Reorder level must be provided. ';
        END IF;
        IF p_supplier_id IS NULL THEN
            v_error_message := v_error_message || 'Supplier ID must be provided. ';
        END IF;
        IF p_category_id IS NULL THEN
            v_error_message := v_error_message || 'Category ID must be provided. ';
        END IF;
        IF p_inventory_id IS NULL THEN
            v_error_message := v_error_message || 'Inventory ID must be provided. ';
        END IF;

        -- Raise error if any null or empty values were found
        IF v_error_message != '' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Error: ' || v_error_message);
        END IF;

        -- Check for negative values
        IF p_price < 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Error: Price must be non-negative.');
        END IF;
        IF p_stock_quantity < 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Error: Stock quantity must be non-negative.');
        END IF;
        IF p_reorder_level < 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Error: Reorder level must be non-negative.');
        END IF;

        -- Check if supplier exists
        IF NOT id_exists(p_supplier_id, 'supplier', 'supplier_id') THEN
            RAISE_APPLICATION_ERROR(-20005, 'Error: Supplier ID ' || p_supplier_id || ' does not exist.');
        END IF;

        -- Check if category exists
        IF NOT id_exists(p_category_id, 'category', 'category_id') THEN
            RAISE_APPLICATION_ERROR(-20006, 'Error: Category ID ' || p_category_id || ' does not exist.');
        END IF;

        -- Check if inventory exists
        IF NOT id_exists(p_inventory_id, 'inventory', 'inventory_id') THEN
            RAISE_APPLICATION_ERROR(-20007, 'Error: Inventory ID ' || p_inventory_id || ' does not exist.');
        END IF;

        -- If all checks pass, proceed with the insert
        INSERT INTO product (
            product_id, product_name, description, price,
            stock_quantity, reorder_level, supplier_supplier_id,
            category_category_id, inventory_inventory_id
        )
        VALUES (
            p_product_id, p_product_name, p_description, p_price,
            p_stock_quantity, p_reorder_level, p_supplier_id,
            p_category_id, p_inventory_id
        );

        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20008, 'Error: Product ID ' || p_product_id || ' already exists.');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20009, 'An unexpected error occurred: ' || SQLERRM);
    END insert_product;

    -- Procedure to update stock quantity of a product
    PROCEDURE update_product_stock(
        p_product_id IN NUMBER,
        p_new_quantity IN NUMBER
    ) IS
        v_old_quantity NUMBER;
        v_inventory_id NUMBER;
        v_quantity_difference NUMBER;
    BEGIN
        -- Check for null values
        IF p_product_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20010, 'Error: Product ID must be provided.');
        END IF;
        IF p_new_quantity IS NULL THEN
            RAISE_APPLICATION_ERROR(-20011, 'Error: New quantity must be provided.');
        END IF;

        -- Check for negative values
        IF p_new_quantity < 0 THEN
            RAISE_APPLICATION_ERROR(-20012, 'Error: New stock quantity must be non-negative.');
        END IF;

        -- Check if product exists
        IF NOT id_exists(p_product_id, 'product', 'product_id') THEN
            RAISE_APPLICATION_ERROR(-20013, 'Error: Product ID ' || p_product_id || ' does not exist.');
        END IF;

        -- Fetch current quantity and inventory details
        SELECT stock_quantity, inventory_inventory_id
        INTO v_old_quantity, v_inventory_id
        FROM product
        WHERE product_id = p_product_id;

        -- Calculate difference in quantity
        v_quantity_difference := p_new_quantity - v_old_quantity;

        -- Update product stock
        UPDATE product
        SET stock_quantity = p_new_quantity
        WHERE product_id = p_product_id;

        -- Update inventory stock
        UPDATE inventory
        SET stock_level = stock_level + v_quantity_difference,
            last_updated = SYSDATE
        WHERE inventory_id = v_inventory_id;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20014, 'An unexpected error occurred: ' || SQLERRM);
    END update_product_stock;



    PROCEDURE update_product_price(
        p_product_id IN NUMBER,  -- Keep as VARCHAR2 to preserve leading zeros
        p_new_price IN NUMBER
    ) IS
        v_product_name VARCHAR2(100);
        v_old_price NUMBER;
    BEGIN
        -- Check for null values
        IF p_product_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20015, 'Error: Product ID must be provided.');
        END IF;
        IF p_new_price IS NULL THEN
            RAISE_APPLICATION_ERROR(-20016, 'Error: New price must be provided.');
        END IF;

        -- Check if the new price is valid (greater than 0)
        IF p_new_price <= 0 THEN
            RAISE_APPLICATION_ERROR(-20017, 'Error: Price must be greater than zero.');
        END IF;

        -- Check if product exists and get current details
        BEGIN
            SELECT product_name, price
            INTO v_product_name, v_old_price
            FROM product
            WHERE TO_CHAR(product_id, 'FM0000') = LPAD(p_product_id, 4, '0');  -- Compare with padded ID
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20018, 'Error: Product ID ' || p_product_id || ' does not exist.');
        END;

        -- Update the price of the specified product
        UPDATE product
        SET price = p_new_price
        WHERE TO_CHAR(product_id, 'FM0000') = LPAD(p_product_id, 4, '0');  -- Use padded ID for update

        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Product updated successfully. Product: ' || v_product_name || 
                             ', Old price: ' || v_old_price || ', New price: ' || p_new_price);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE = -2290 THEN
                RAISE_APPLICATION_ERROR(-20019, 'Error: Invalid price. Check constraints violated.');
            ELSE
                RAISE_APPLICATION_ERROR(-20020, 'An unexpected error occurred: ' || SQLERRM);
            END IF;
    END update_product_price;
    
    
    
    -- Procedure to check if stock is below the reorder level
    PROCEDURE check_low_stock(
        p_product_id IN NUMBER
    ) IS
        v_stock_quantity NUMBER;
        v_reorder_level NUMBER;
    BEGIN
        -- Check for null values
        IF p_product_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20020, 'Error: Product ID must be provided.');
        END IF;

        -- Check if product exists
        IF NOT id_exists(p_product_id, 'product', 'product_id') THEN
            RAISE_APPLICATION_ERROR(-20021, 'Error: Product ID ' || p_product_id || ' does not exist.');
        END IF;

        SELECT stock_quantity, reorder_level
        INTO v_stock_quantity, v_reorder_level
        FROM product
        WHERE product_id = p_product_id;

        IF v_stock_quantity <= v_reorder_level THEN
            DBMS_OUTPUT.PUT_LINE('Product ' || p_product_id || ' is low on stock. Reorder is needed.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Product ' || p_product_id || ' stock is sufficient.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20022, 'An unexpected error occurred: ' || SQLERRM);
    END check_low_stock;

END pkg_inventory_management;
/

SHOW ERRORS PACKAGE pkg_inventory_management;