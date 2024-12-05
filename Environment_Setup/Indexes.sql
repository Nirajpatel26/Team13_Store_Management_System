SET SERVEROUTPUT ON;
SET TIMING ON;

-- Indexes for the Orders table
BEGIN
   EXECUTE IMMEDIATE 'DROP INDEX idx_orders_customer_customer_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/
CREATE INDEX idx_orders_customer_customer_id ON orders (customer_customer_id);

BEGIN
   EXECUTE IMMEDIATE 'DROP INDEX idx_orders_order_date';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/
CREATE INDEX idx_orders_order_date ON orders (order_date);

-- Indexes for the Product table
BEGIN
   EXECUTE IMMEDIATE 'DROP INDEX idx_product_name';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/
CREATE INDEX idx_product_name ON product (product_name);

BEGIN
   EXECUTE IMMEDIATE 'DROP INDEX idx_product_stock_quantity';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/
CREATE INDEX idx_product_stock_quantity ON product (stock_quantity);

-- Composite index for Product table
BEGIN
   EXECUTE IMMEDIATE 'DROP INDEX idx_product_name_category_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/
CREATE INDEX idx_product_name_category_id ON product (product_name, category_category_id);

-- Indexes for the Customer table
BEGIN
   EXECUTE IMMEDIATE 'DROP INDEX idx_customer_loyalty_program_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/
CREATE INDEX idx_customer_loyalty_program_id ON customer (loyalty_program_loyalty_id);

-- Indexes for the Order_Detail table
BEGIN
   EXECUTE IMMEDIATE 'DROP INDEX idx_order_detail_product_product_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/
CREATE INDEX idx_order_detail_product_product_id ON order_detail (product_product_id);

BEGIN
   EXECUTE IMMEDIATE 'DROP INDEX idx_order_detail_order_order_id';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/
CREATE INDEX idx_order_detail_order_order_id ON order_detail (order_order_id);

-- Composite index for Order_Detail table
BEGIN
   EXECUTE IMMEDIATE 'DROP INDEX idx_order_detail_product_order';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/
CREATE INDEX idx_order_detail_product_order ON order_detail (product_product_id, order_order_id);

-- Index for Inventory table
BEGIN
   EXECUTE IMMEDIATE 'DROP INDEX idx_inventory_stock_level';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/
CREATE INDEX idx_inventory_stock_level ON inventory (stock_level);

-- Index for Loyalty_Program table
BEGIN
   EXECUTE IMMEDIATE 'DROP INDEX idx_loyalty_program_name';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/
CREATE INDEX idx_loyalty_program_name ON loyalty_program (program_name);
