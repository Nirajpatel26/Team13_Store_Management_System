SET SERVEROUTPUT ON;

--check low stock
BEGIN
    APP_ADMIN.pkg_inventory_management.check_low_stock(p_product_id => 1);
END;
/