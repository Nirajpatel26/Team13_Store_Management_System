CREATE OR REPLACE FUNCTION calculate_total_amount(
    p_order_id IN NUMBER,
    p_customer_id IN NUMBER
) RETURN NUMBER IS
    v_total_amount NUMBER := 0;
    v_discount_percent NUMBER := 0;
BEGIN
    -- Calculate the total amount from order details
    SELECT SUM(quantity * price_at_purchase)
    INTO v_total_amount
    FROM order_detail
    WHERE order_order_id = p_order_id;
    -- Check for loyalty discount
    SELECT NVL(lp.discount_percentage, 0)
    INTO v_discount_percent
    FROM customer c
    LEFT JOIN loyalty_program lp ON c.loyalty_program_loyalty_id = lp.loyalty_id
    WHERE c.customer_id = p_customer_id
    AND SYSDATE BETWEEN lp.start_date AND lp.end_date;
    -- Apply discount if applicable
    IF v_discount_percent > 0 THEN
        v_total_amount := v_total_amount * (1 - (v_discount_percent/100));
    END IF;
    RETURN v_total_amount;
END;
/