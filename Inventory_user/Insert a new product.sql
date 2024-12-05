SET SERVEROUTPUT ON;


-- Insert a new product
BEGIN
    APP_ADMIN.pkg_inventory_management.insert_product(
        p_product_id => 10,
        p_product_name => ' Mouse',
        p_description => 'Ergonomic wireless mouse',
        p_price => 25.99,
        p_stock_quantity => 100,
        p_reorder_level => 20,
        p_supplier_id => 1,
        p_category_id => 3,
        p_inventory_id => 2
    );
    DBMS_OUTPUT.PUT_LINE('Product inserted successfully.');
END;
/


