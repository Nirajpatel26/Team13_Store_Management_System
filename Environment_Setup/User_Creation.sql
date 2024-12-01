SET SERVEROUTPUT ON;
-- Drop existing users
BEGIN
    FOR user_rec IN (SELECT username FROM all_users WHERE username IN ('MANAGER_USER', 'CASHIER_USER', 'INVENTORY_USER', 'MARKETING_USER')) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP USER ' || user_rec.username || ' CASCADE';
            DBMS_OUTPUT.PUT_LINE('Dropped user: ' || user_rec.username);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Could not drop user ' || user_rec.username || ': ' || SQLERRM);
        END;
    END LOOP;
END;
/

-- Create Users and Grant Privileges
BEGIN
    -- Create and grant privileges to MANAGER_USER
BEGIN
        EXECUTE IMMEDIATE 'CREATE USER MANAGER_USER IDENTIFIED BY "ManagerPass2023"';
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO MANAGER_USER';

        -- Grant full privileges for Manager on specified tables
        EXECUTE IMMEDIATE 'GRANT SELECT ON INVENTORY_OVERVIEW TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON CUSTOMER_PURCHASE_HISTORY TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON TOP_SELLING_PRODUCTS TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON DAILY_SALES_SUMMARY TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON SUPPLIER_PRODUCTS TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON LOYALTY_PROGRAM_PARTICIPATION TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON LOW_STOCK_ALERT TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON SALES_TRENDS TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON LATEST_CUSTOMER_INVOICE TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON ALL_INVOICE TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON SALES_PERFORMANCE TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON CUSTOMER_LIFETIME_VALUE TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON CATEGORY_PERFORMANCE TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON SEASONAL_SALES_TRENDS TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON update_order_status TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON generate_sales_report TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON pkg_inventory_management TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON SUPPLIER_PERFORMANCE TO MANAGER_USER';

        EXECUTE IMMEDIATE 'GRANT EXECUTE ON INSERT_EMPLOYEE TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON INSERT_LOYALTY_PROGRAM TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON loyalty_program TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON orders TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON order_detail TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON customer TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON marketing TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON employee TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON pay_method TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON supplier TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON sales_transaction TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON product TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON category TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON reorder_request TO MANAGER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON inventory TO MANAGER_USER';

        DBMS_OUTPUT.PUT_LINE('Created MANAGER_USER and granted privileges.');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error creating MANAGER_USER: ' || SQLERRM);
    END;
    -- Create and grant privileges to Inventory_User
    BEGIN
        EXECUTE IMMEDIATE 'CREATE USER INVENTORY_USER IDENTIFIED BY "InventoryPass2023"';
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO INVENTORY_USER';

        -- Grant limited privileges for Inventory Manager
        EXECUTE IMMEDIATE 'GRANT SELECT ON INVENTORY_OVERVIEW TO INVENTORY_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON SUPPLIER_PRODUCTS TO INVENTORY_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON LOW_STOCK_ALERT TO INVENTORY_USER';
        
        
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE ON product TO INVENTORY_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE ON inventory TO INVENTORY_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE ON supplier TO INVENTORY_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE ON category TO INVENTORY_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE ON reorder_request TO INVENTORY_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON INSERT_PRODUCT TO INVENTORY_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON INSERT_INVENTORY TO INVENTORY_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON INSERT_SUPPLIER TO INVENTORY_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON INSERT_CATEGORY TO INVENTORY_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON INSERT_REORDER_REQUEST TO INVENTORY_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON SUPPLIER_PERFORMANCE TO INVENTORY_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON CATEGORY_PERFORMANCE TO INVENTORY_USER' ;
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON update_reorder_request TO INVENTORY_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON update_reorder_status TO INVENTORY_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON pkg_inventory_management TO INVENTORY_USER';

        DBMS_OUTPUT.PUT_LINE('Created INVENTORY_USER and granted privileges.');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error creating INVENTORY_USER: ' || SQLERRM);
    END;
     -- Create and grant privileges to CASHIER_USER
   BEGIN
        EXECUTE IMMEDIATE 'CREATE USER CASHIER_USER IDENTIFIED BY "CashierPass2023"';
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO CASHIER_USER';

        -- Selective privileges for Cashier
        
        EXECUTE IMMEDIATE 'GRANT SELECT ON LOYALTY_PROGRAM_PARTICIPATION TO CASHIER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON LATEST_CUSTOMER_INVOICE TO CASHIER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON ALL_INVOICE TO CASHIER_USER';
    
        EXECUTE IMMEDIATE 'GRANT INSERT,SELECT, UPDATE (first_name, last_name, email, phone, address) ON customer TO CASHIER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON loyalty_program TO CASHIER_USER';
        EXECUTE IMMEDIATE 'GRANT INSERT, UPDATE, DELETE ON orders TO CASHIER_USER';
        EXECUTE IMMEDIATE 'GRANT INSERT, UPDATE, DELETE ON order_detail TO CASHIER_USER';
        EXECUTE IMMEDIATE 'GRANT INSERT, SELECT ON sales_transaction TO CASHIER_USER';
        EXECUTE IMMEDIATE 'GRANT INSERT, SELECT ON pay_method TO CASHIER_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON product TO CASHIER_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON INSERT_CUSTOMER TO CASHIER_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON INSERT_ORDER TO CASHIER_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON INSERT_ORDER_DETAIL TO CASHIER_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON INSERT_SALES_TRANSACTION TO CASHIER_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON INSERT_PAYMENT_METHOD TO CASHIER_USER';

         
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON recommend_related_products TO CASHIER_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON update_order_status TO CASHIER_USER ';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON ADD_ORDER TO CASHIER_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON insert_customer_with_loyalty TO CASHIER_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON ADD_ORDER TO CASHIER_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON insert_customer_with_loyalty TO CASHIER_USER';


        DBMS_OUTPUT.PUT_LINE('Created CASHIER_USER and granted privileges.');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error creating CASHIER_USER: ' || SQLERRM);
    END;
    -- Create and grant privileges to MARKETING_USER
     -- Create and grant privileges to MARKETING_USER
    BEGIN
        EXECUTE IMMEDIATE 'CREATE USER MARKETING_USER IDENTIFIED BY "MarketingPass2023"';
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO MARKETING_USER';

        -- Selective privileges for Marketing User
        
        EXECUTE IMMEDIATE 'GRANT SELECT ON CUSTOMER_PURCHASE_HISTORY TO MARKETING_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON TOP_SELLING_PRODUCTS TO MARKETING_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON LOYALTY_PROGRAM_PARTICIPATION TO MARKETING_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON SALES_TRENDS TO MARKETING_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON LATEST_CUSTOMER_INVOICE TO MARKETING_USER';
        
        EXECUTE IMMEDIATE 'GRANT INSERT, SELECT, UPDATE ON marketing TO MARKETING_USER';
        EXECUTE IMMEDIATE 'GRANT SELECT ON customer TO MARKETING_USER';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON INSERT_MARKETING TO MARKETING_USER';
        
        EXECUTE IMMEDIATE 'GRANT SELECT ON CUSTOMER_LIFETIME_VALUE TO MARKETING_USER' ;
        EXECUTE IMMEDIATE 'GRANT SELECT ON SEASONAL_SALES_TRENDS TO MARKETING_USER' ;
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON generate_sales_report TO MARKETING_USER';
 
        DBMS_OUTPUT.PUT_LINE('Created MARKETING_USER and granted privileges.');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error creating MARKETING_USER: ' || SQLERRM);
    END;
    
    -- Final output confirmation
    DBMS_OUTPUT.PUT_LINE('All users created and privileges granted successfully.');
END;
/

