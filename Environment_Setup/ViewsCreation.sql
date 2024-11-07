SET SERVEROUTPUT ON;
-- Drop existing views
BEGIN
    FOR view_rec IN (SELECT view_name FROM user_views WHERE view_name IN (
        'INVENTORY_OVERVIEW',
        'CUSTOMER_PURCHASE_HISTORY',
        'TOP_SELLING_PRODUCTS',
        'DAILY_SALES_SUMMARY',
        'SUPPLIER_PRODUCTS',
        'LOYALTY_PROGRAM_PARTICIPATION',
        'LOW_STOCK_ALERT',
        'SALES_TRENDS',
        'ALL_INVOICE',
        'LATEST_CUSTOMER_INVOICE'
    ))
    LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP VIEW ' || view_rec.view_name;
            DBMS_OUTPUT.PUT_LINE('Dropped view: ' || view_rec.view_name);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Could not drop view ' || view_rec.view_name || ': ' || SQLERRM);
        END;
    END LOOP;
END;
/
-- Create Views
BEGIN
    -- INVENTORY_OVERVIEW
-- INVENTORY_OVERVIEW
    EXECUTE IMMEDIATE '
    CREATE OR REPLACE VIEW INVENTORY_OVERVIEW AS
    SELECT 
        i.inventory_id,
        i.stock_level AS overall_stock_level,
        LISTAGG(p.product_name, '', '') WITHIN GROUP (ORDER BY p.product_name) AS product_list,
        COUNT(DISTINCT p.product_id) AS product_count,
    CASE 
        WHEN EXISTS (
            SELECT 1
            FROM product p_sub
            WHERE p_sub.inventory_inventory_id = i.inventory_id
              AND p_sub.stock_quantity <= p_sub.reorder_level
        ) THEN ''Restock Needed: '' || LISTAGG(
            CASE 
                WHEN p.stock_quantity <= p.reorder_level THEN p.product_name
                ELSE NULL
            END, '', '') WITHIN GROUP (ORDER BY p.product_name)
        ELSE ''In Stock''
    END AS inventory_status
    FROM
        inventory i
    LEFT JOIN
        product p ON i.inventory_id = p.inventory_inventory_id
    GROUP BY
        i.inventory_id, i.stock_level';
    DBMS_OUTPUT.PUT_LINE('Created view: INVENTORY_OVERVIEW');





    -- CUSTOMER_PURCHASE_HISTORY
    EXECUTE IMMEDIATE '
    CREATE OR REPLACE VIEW CUSTOMER_PURCHASE_HISTORY AS
    SELECT
        c.customer_id,
        c.first_name || '' '' || c.last_name AS customer_name,
        o.order_id,
        o.order_date,
        od.product_product_id,
        p.product_name,
        od.quantity,
        od.price_at_purchase * od.quantity AS total_spent
    FROM
        customer c
    JOIN
        orders o ON c.customer_id = o.customer_customer_id
    JOIN
        order_detail od ON o.order_id = od.order_order_id
    JOIN
        product p ON od.product_product_id = p.product_id';
    DBMS_OUTPUT.PUT_LINE('Created view: CUSTOMER_PURCHASE_HISTORY');

    -- TOP_SELLING_PRODUCTS
    EXECUTE IMMEDIATE '
    CREATE OR REPLACE VIEW TOP_SELLING_PRODUCTS AS
    SELECT
        p.product_id,
        p.product_name,
        SUM(od.quantity) AS total_quantity_sold
    FROM
        product p
    JOIN
        order_detail od ON p.product_id = od.product_product_id
    GROUP BY
        p.product_id, p.product_name
    ORDER BY
        total_quantity_sold DESC';
    DBMS_OUTPUT.PUT_LINE('Created view: TOP_SELLING_PRODUCTS');

    -- DAILY_SALES_SUMMARY
    EXECUTE IMMEDIATE '
    CREATE OR REPLACE VIEW DAILY_SALES_SUMMARY AS
    SELECT
        o.order_date,
        COUNT(o.order_id) AS total_transactions,
        SUM(o.total_amount) AS total_revenue
    FROM
        orders o
    GROUP BY
        o.order_date
    ORDER BY
        o.order_date';
    DBMS_OUTPUT.PUT_LINE('Created view: DAILY_SALES_SUMMARY');

    -- SUPPLIER_PRODUCTS
    EXECUTE IMMEDIATE '
    CREATE OR REPLACE VIEW SUPPLIER_PRODUCTS AS
    SELECT
        s.supplier_id,
        s.supplier_name,
        p.product_id,
        p.product_name,
        r.quantity_requested,
        r.status AS delivery_status
    FROM
        supplier s
    JOIN
        product p ON s.supplier_id = p.supplier_supplier_id
    LEFT JOIN
        reorder_request r ON p.product_id = r.product_product_id';
    DBMS_OUTPUT.PUT_LINE('Created view: SUPPLIER_PRODUCTS');

    -- LOYALTY_PROGRAM_PARTICIPATION
    EXECUTE IMMEDIATE '
    CREATE OR REPLACE VIEW LOYALTY_PROGRAM_PARTICIPATION AS
    SELECT
        c.customer_id,
        c.first_name || '' '' || c.last_name AS customer_name,
        lp.program_name,
        lp.discount_percentage
    FROM
        customer c
    JOIN
        loyalty_program lp ON c.loyalty_program_loyalty_id = lp.loyalty_id';
    DBMS_OUTPUT.PUT_LINE('Created view: LOYALTY_PROGRAM_PARTICIPATION');

    -- LOW_STOCK_ALERT
    EXECUTE IMMEDIATE '
    CREATE OR REPLACE VIEW LOW_STOCK_ALERT AS
    SELECT
        p.product_id,
        p.product_name,
        p.stock_quantity,
        p.reorder_level
    FROM
        product p
    WHERE
        p.stock_quantity <= p.reorder_level';
    DBMS_OUTPUT.PUT_LINE('Created view: LOW_STOCK_ALERT');

    -- SALES_TRENDS
    EXECUTE IMMEDIATE '
    CREATE OR REPLACE VIEW SALES_TRENDS AS
    SELECT
        o.order_date,
        COUNT(o.order_id) AS total_transactions,
        SUM(o.total_amount) AS total_revenue,
        CASE WHEN COUNT(o.order_id) > 0 THEN SUM(o.total_amount) / COUNT(o.order_id) ELSE 0 END AS avg_transaction_value
    FROM
        orders o
    GROUP BY
        o.order_date
    ORDER BY
        o.order_date';
    DBMS_OUTPUT.PUT_LINE('Created view: SALES_TRENDS');

    -- ALL_INVOICE
    EXECUTE IMMEDIATE '
    CREATE OR REPLACE VIEW ALL_INVOICE AS
    SELECT
        o.order_id,
        o.order_date,
        c.customer_id,
        c.first_name || '' '' || c.last_name AS customer_name,
        p.product_id,
        p.product_name,
        od.quantity,
        od.price_at_purchase AS unit_price,
        (od.quantity * od.price_at_purchase) AS item_total,
        o.total_amount AS order_total,
        o.status AS order_status,
        ROW_NUMBER() OVER (PARTITION BY o.order_id ORDER BY p.product_id) AS item_number
    FROM
        orders o
    JOIN
        customer c ON o.customer_customer_id = c.customer_id
    JOIN
        order_detail od ON o.order_id = od.order_order_id
    JOIN
        product p ON od.product_product_id = p.product_id
    ORDER BY
        o.order_id, item_number';
    DBMS_OUTPUT.PUT_LINE('Created view: ALL_INVOICE');

    EXECUTE IMMEDIATE '
    CREATE OR REPLACE VIEW LATEST_CUSTOMER_INVOICE AS
    WITH latest_order AS (
    SELECT MAX(order_id) AS latest_order_id
    FROM orders
    )
    SELECT
        o.order_id,
        o.order_date,
        c.customer_id,
        c.first_name AS customer_first_name,
        c.last_name AS customer_last_name,
        c.email AS customer_email,
        c.phone AS customer_phone,
        p.product_id,
        p.product_name,
        od.quantity,
        od.price_at_purchase AS unit_price,
        (od.quantity * od.price_at_purchase) AS item_total,
        o.total_amount AS order_total,
        o.status AS order_status
    FROM
        orders o
    JOIN
        latest_order lo ON o.order_id = lo.latest_order_id
    JOIN
        customer c ON o.customer_customer_id = c.customer_id
    JOIN
        order_detail od ON o.order_id = od.order_order_id
    JOIN
        product p ON od.product_product_id = p.product_id
    ORDER BY
        p.product_id';
    DBMS_OUTPUT.PUT_LINE('Created view: LATEST_CUSTOMER_INVOICE');
    DBMS_OUTPUT.PUT_LINE('All views created successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error creating views: ' || SQLERRM);
END;
/
