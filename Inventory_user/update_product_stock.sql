SET SERVEROUTPUT ON;


-- Update product stock
BEGIN
    APP_ADMIN.pkg_inventory_management.update_product_stock(
        p_product_id => 1,
        p_new_quantity => 900
    );
    DBMS_OUTPUT.PUT_LINE('Product stock updated successfully.');
END;
/



--trying nonexistent 
BEGIN
    APP_ADMIN.pkg_inventory_management.update_product_stock(
        p_product_id => 999,  -- Non-existent product ID
        p_new_quantity => 100
    );
END;
/
