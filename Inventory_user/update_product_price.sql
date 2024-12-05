SET SERVEROUTPUT ON;


-- Update product stock
BEGIN
    APP_ADMIN.pkg_inventory_management.update_product_price(
        p_product_id => 1,
        p_new_price => 200
    );
    DBMS_OUTPUT.PUT_LINE('Product stock updated successfully.');
END;
/
