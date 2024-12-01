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

    PROCEDURE check_low_stock(
        p_product_id IN NUMBER
    );
END pkg_inventory_management;
/



CREATE OR REPLACE PACKAGE BODY pkg_inventory_management IS

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
    BEGIN
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
    END update_product_stock;

    -- Procedure to check if stock is below the reorder level
    PROCEDURE check_low_stock(
        p_product_id IN NUMBER
    ) IS
        v_stock_quantity NUMBER;
        v_reorder_level NUMBER;
    BEGIN
        SELECT stock_quantity, reorder_level
        INTO v_stock_quantity, v_reorder_level
        FROM product
        WHERE product_id = p_product_id;

        IF v_stock_quantity <= v_reorder_level THEN
            DBMS_OUTPUT.PUT_LINE('Product ' || p_product_id || ' is low on stock. Reorder is needed.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Product ' || p_product_id || ' stock is sufficient.');
        END IF;
    END check_low_stock;

END pkg_inventory_management;
/

SHOW ERRORS PACKAGE pkg_inventory_management;








