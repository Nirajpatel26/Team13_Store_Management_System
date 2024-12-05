

CREATE OR REPLACE TRIGGER trg_prevent_negative_stock
BEFORE UPDATE OF stock_quantity ON product
FOR EACH ROW
BEGIN
    IF :NEW.stock_quantity < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Stock quantity cannot be negative.');
    END IF;
END;
/



CREATE OR REPLACE TRIGGER trg_loyalty_expiration
BEFORE UPDATE OF end_date ON loyalty_program
FOR EACH ROW
BEGIN
    IF :NEW.end_date < SYSDATE THEN
        UPDATE customer
        SET loyalty_program_loyalty_id = NULL
        WHERE loyalty_program_loyalty_id = :OLD.loyalty_id;
    END IF;
END;
/


CREATE OR REPLACE TRIGGER trg_validate_product_price
BEFORE INSERT OR UPDATE OF price ON product
FOR EACH ROW
BEGIN
    IF :NEW.price < 1 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Product price must be at least $1.00.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_check_reorder_level
AFTER UPDATE OF stock_quantity ON product
FOR EACH ROW
BEGIN
    -- Check if stock_quantity falls below reorder_level
    IF :NEW.stock_quantity < :NEW.reorder_level THEN
        -- Insert into reorder_request table
        INSERT INTO reorder_request (
            reorder_request_id,
            product_product_id,
            status,
            quantity_requested
        )
        VALUES (
            reorder_request_seq.NEXTVAL, -- Assuming a sequence for request IDs
            :NEW.product_id,
            'Pending',
            :NEW.reorder_level - :NEW.stock_quantity -- Calculate quantity to reorder
        );
    END IF;
END trg_check_reorder_level;