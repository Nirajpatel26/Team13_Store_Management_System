-- Drop tables if they already exist to avoid errors
BEGIN
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE category CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE customer CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE employee CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE inventory CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE loyalty_program CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE marketing CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE orders CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE order_detail CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE pay_method CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE product CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE reorder_request CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE sales_transaction CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE supplier CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
END;
/

-- Create tables
CREATE TABLE category (
    category_id   INTEGER NOT NULL,
    category_name VARCHAR2(100) NOT NULL,
    description   VARCHAR2(100),
    CONSTRAINT category_pk PRIMARY KEY (category_id),
    CONSTRAINT category_category_name_un UNIQUE (category_name)
);

CREATE TABLE customer (
    customer_id                INTEGER NOT NULL,
    first_name                 VARCHAR2(100) NOT NULL,
    last_name                  VARCHAR2(100) NOT NULL,
    email                      VARCHAR2(100) NOT NULL,
    phone                      NUMBER(10) NOT NULL,
    address                    VARCHAR2(255) NOT NULL,
    loyalty_program_loyalty_id NUMBER(5),
    CONSTRAINT customer_pk PRIMARY KEY (customer_id),
    CONSTRAINT customer_email_un UNIQUE (email),
    CONSTRAINT customer_phone_ck CHECK (phone >= 0)
);

CREATE TABLE employee (
    employee_id INTEGER NOT NULL,
    first_name  VARCHAR2(100) NOT NULL,
    last_name   VARCHAR2(100) NOT NULL,
    email       VARCHAR2(100) NOT NULL,
    phone       NUMBER(10) NOT NULL,
    address     VARCHAR2(100) NOT NULL,
    position    VARCHAR2(50) NOT NULL,
    hire_date   DATE NOT NULL,
    salary      NUMBER(10, 2) NOT NULL,
    CONSTRAINT employee_pk PRIMARY KEY (employee_id),
    CONSTRAINT employee_email_un UNIQUE (email),
    CONSTRAINT employee_phone_ck CHECK (phone >= 0),
    CONSTRAINT employee_salary_ck CHECK (salary >= 0)
);

CREATE TABLE inventory (
    inventory_id INTEGER NOT NULL,
    stock_level  INTEGER NOT NULL CHECK (stock_level >= 0),
    last_updated DATE,
    CONSTRAINT inventory_pk PRIMARY KEY (inventory_id)
);

CREATE TABLE loyalty_program (
    loyalty_id          NUMBER(5) NOT NULL,
    program_name        VARCHAR2(100) NOT NULL,
    discount_percentage NUMBER(5, 2) CHECK (discount_percentage BETWEEN 0 AND 100),
    start_date          DATE NOT NULL,
    end_date            DATE,
    CONSTRAINT loyalty_program_pk PRIMARY KEY (loyalty_id),
    CONSTRAINT loyalty_program_date_ck CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE marketing (
    marketing_id         INTEGER NOT NULL,
    message              VARCHAR2(1000) NOT NULL,
    sent_via             VARCHAR2(100) NOT NULL,
    date_sent            DATE NOT NULL,
    discount_offered     NUMBER(10, 2),
    customer_customer_id INTEGER
);
ALTER TABLE marketing ADD CONSTRAINT marketing_pk PRIMARY KEY ( marketing_id );

-- Renamed the Order table to ORDERS and removed SYSDATE from check constraint
CREATE TABLE orders (
    order_id             INTEGER NOT NULL,
    order_date           DATE NOT NULL,
    total_amount         NUMBER(10, 2) CHECK (total_amount >= 0),
    status               VARCHAR2(100) DEFAULT 'Pending',
    customer_customer_id INTEGER NOT NULL,
    CONSTRAINT order_pk PRIMARY KEY (order_id),
    CONSTRAINT order_customer_fk FOREIGN KEY (customer_customer_id) REFERENCES customer(customer_id)
);
CREATE TABLE pay_method (
    payment_id   INTEGER NOT NULL,
    payment_type VARCHAR2(50) NOT NULL,
    CONSTRAINT pay_method_pk PRIMARY KEY (payment_id)
);



CREATE TABLE supplier (
    supplier_id   INTEGER NOT NULL,
    supplier_name VARCHAR2(100) NOT NULL,
    contact_name  VARCHAR2(100) NOT NULL,
    phone         NUMBER(10) NOT NULL,
    email         VARCHAR2(100) NOT NULL,
    address       VARCHAR2(255) NOT NULL,
    CONSTRAINT supplier_pk PRIMARY KEY (supplier_id),
    CONSTRAINT supplier_name_un UNIQUE (supplier_name),
    CONSTRAINT supplier_email_un UNIQUE (email),
    CONSTRAINT supplier_phone_ck CHECK (phone >= 0)
);


CREATE TABLE product (
    product_id             INTEGER NOT NULL,
    product_name           VARCHAR2(100) NOT NULL,
    description            VARCHAR2(200),
    price                  NUMBER(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity         INTEGER NOT NULL CHECK (stock_quantity >= 0),
    reorder_level          INTEGER CHECK (reorder_level >= 0),
    supplier_supplier_id   INTEGER,
    category_category_id   INTEGER,
    inventory_inventory_id INTEGER NOT NULL,
    CONSTRAINT product_pk PRIMARY KEY (product_id),
    CONSTRAINT product_category_fk FOREIGN KEY (category_category_id) REFERENCES category(category_id),
    CONSTRAINT product_inventory_fk FOREIGN KEY (inventory_inventory_id) REFERENCES inventory(inventory_id),
    CONSTRAINT product_supplier_fk FOREIGN KEY (supplier_supplier_id) REFERENCES supplier(supplier_id)
);

CREATE TABLE order_detail (
    order_detail_id    INTEGER NOT NULL,
    quantity           INTEGER NOT NULL CHECK (quantity > 0),
    price_at_purchase  NUMBER(10, 2) NOT NULL CHECK (price_at_purchase >= 0),
    order_order_id     INTEGER NOT NULL,
    product_product_id INTEGER NOT NULL,
    CONSTRAINT order_detail_pk PRIMARY KEY (order_detail_id),
    CONSTRAINT order_detail_order_fk FOREIGN KEY (order_order_id) REFERENCES orders(order_id),
    CONSTRAINT order_detail_product_fk FOREIGN KEY (product_product_id) REFERENCES product(product_id)
);

CREATE TABLE reorder_request (
    reorder_request_id     INTEGER NOT NULL,
    quantity_requested     INTEGER NOT NULL CHECK (quantity_requested > 0),
    request_date           DATE,
    expected_delivery_date DATE,
    actual_delivery_date   DATE,
    status                 VARCHAR2(25),
    product_product_id     INTEGER,
    supplier_supplier_id   INTEGER,
    inventory_inventory_id INTEGER,
    CONSTRAINT reorder_request_pk PRIMARY KEY (reorder_request_id),
    CONSTRAINT reorder_request_inventory_fk FOREIGN KEY (inventory_inventory_id) REFERENCES inventory(inventory_id),
    CONSTRAINT reorder_request_product_fk FOREIGN KEY (product_product_id) REFERENCES product(product_id),
    CONSTRAINT reorder_request_supplier_fk FOREIGN KEY (supplier_supplier_id) REFERENCES supplier(supplier_id)
);

CREATE TABLE sales_transaction (
    tran_id               INTEGER NOT NULL,
    transaction_date      DATE NOT NULL,
    order_order_id        INTEGER,
    pay_method_payment_id INTEGER NOT NULL,
    employee_employee_id  INTEGER,
    CONSTRAINT sales_transaction_pk PRIMARY KEY (tran_id),
    CONSTRAINT sales_transaction_employee_fk FOREIGN KEY (employee_employee_id) REFERENCES employee(employee_id),
    CONSTRAINT sales_transaction_order_fk FOREIGN KEY (order_order_id) REFERENCES orders(order_id),
    CONSTRAINT sales_transaction_pay_method_fk FOREIGN KEY (pay_method_payment_id) REFERENCES pay_method(payment_id)
);



-- Foreign Key for customer and loyalty_program
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE customer ADD CONSTRAINT customer_loyalty_program_fk FOREIGN KEY (loyalty_program_loyalty_id) REFERENCES loyalty_program(loyalty_id)';
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/
