SET SERVEROUTPUT ON;
SET TIMING ON;

-- Indexes for the Orders table
CREATE INDEX idx_orders_customer_customer_id ON orders (customer_customer_id);
CREATE INDEX idx_orders_order_date ON orders (order_date);

-- Indexes for the Product table
CREATE INDEX idx_product_name ON product (product_name);
CREATE INDEX idx_product_stock_quantity ON product (stock_quantity);

-- Composite index for Product table
CREATE INDEX idx_product_name_category_id ON product (product_name, category_category_id);

-- Indexes for the Customer table
CREATE INDEX idx_customer_email ON customer (email);
CREATE INDEX idx_customer_loyalty_program_id ON customer (loyalty_program_loyalty_id);

-- Indexes for the Order_Detail table
CREATE INDEX idx_order_detail_product_product_id ON order_detail (product_product_id);
CREATE INDEX idx_order_detail_order_order_id ON order_detail (order_order_id);

-- Composite index for Order_Detail table
CREATE INDEX idx_order_detail_product_order ON order_detail (product_product_id, order_order_id);

-- Index for Inventory table
CREATE INDEX idx_inventory_stock_level ON inventory (stock_level);

-- Index for Loyalty_Program table
CREATE INDEX idx_loyalty_program_name ON loyalty_program (program_name);

-- Index for Supplier table
CREATE INDEX idx_supplier_name ON supplier (supplier_name);

-- Index for Category table
CREATE INDEX idx_category_name ON category (category_name);

