BEGIN
    APP_ADMIN.update_reorder_status(
        p_reorder_request_id => 4,          -- ID of the reorder request to update
        p_status => 'Delivered',            -- New status for the reorder request
        p_actual_delivery_date => SYSDATE  -- Actual delivery date (current date)
    );
END;
/
