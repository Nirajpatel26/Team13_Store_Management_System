BEGIN
    APP_ADMIN.update_reorder_request(
        p_reorder_request_id => 4,          -- ID of the reorder request to update
        p_quantity_requested => 100,       -- Quantity requested for reorder
        p_request_date => SYSDATE,         -- Date of request
        p_expected_delivery_date => SYSDATE + 7, -- Expected delivery date (7 days from now)
        p_actual_delivery_date => NULL,     -- Actual delivery date (if known)
        p_status => 'Ordered',             -- Status of the request (e.g., 'Ordered')
        p_supplier_id => 3,              -- Supplier ID responsible for this product
        p_INVENTORY_ID => 2             ---- INVENTORY ID to which product 
    );
END;
/