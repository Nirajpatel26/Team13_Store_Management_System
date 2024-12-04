-- Insert categories
BEGIN
    APP_ADMIN.INSERT_CATEGORY(1, 'Grains', 'Various types of grains');
    APP_ADMIN.INSERT_CATEGORY(2, 'Flour', 'Different types of flour');
    APP_ADMIN.INSERT_CATEGORY(3, 'Tea', 'Various tea blends');
    APP_ADMIN.INSERT_CATEGORY(4, 'Spices', 'Assorted spices and seasonings');
    APP_ADMIN.INSERT_CATEGORY(5, 'Dairy', 'Dairy products');
    APP_ADMIN.INSERT_CATEGORY(6, 'Snacks', 'Assorted snack items');
    APP_ADMIN.INSERT_CATEGORY(7, 'Beverages', 'Non-alcoholic drinks');
END;
/
-- Insert inventory
BEGIN
    APP_ADMIN.INSERT_INVENTORY(1, 830, TO_DATE('2024-11-05', 'YYYY-MM-DD'));
    APP_ADMIN.INSERT_INVENTORY(2, 800, TO_DATE('2024-11-05', 'YYYY-MM-DD'));
    APP_ADMIN.INSERT_INVENTORY(3, 730, TO_DATE('2024-11-05', 'YYYY-MM-DD'));
END;
/

BEGIN
    APP_ADMIN.INSERT_SUPPLIER(1, 'Sharma Grains Ltd.', 'Amit Sharma', 9876543220, 'amit.sharma@gmail.com', '789 Rice St, Punjab');
    APP_ADMIN.INSERT_SUPPLIER(2, 'Patel Flour Mills', 'Neha Patel', 9876543221, 'neha.patel@yahoo.com', '101 Wheat Rd, Gujarat');
    APP_ADMIN.INSERT_SUPPLIER(3, 'Gupta Tea Traders', 'Rahul Gupta', 9876543222, 'rahul.gupta@gmail.com', '202 Tea Garden, Assam');
    APP_ADMIN.INSERT_SUPPLIER(4, 'Singh Spice Co.', 'Harpreet Singh', 9876543223, 'harpreet.singh@outlook.com', '303 Spice Market, Rajasthan');
    APP_ADMIN.INSERT_SUPPLIER(5, 'Verma Dairy Products', 'Anjali Verma', 9876543224, 'anjali.verma@yahoo.com', '404 Milk Colony, Haryana');
END;
/
-- Insert products
BEGIN
    APP_ADMIN.INSERT_PRODUCT(1, 'Basmati Rice', 'Premium long-grain rice', 100.00, 500, 100, 1, 1, 1);
    APP_ADMIN.INSERT_PRODUCT(2, 'Whole Wheat Atta', 'Stone-ground whole wheat flour', 50.00, 300, 50, 2, 2, 1);
    APP_ADMIN.INSERT_PRODUCT(3, 'Masala Chai', 'Aromatic Indian spiced tea', 75.00, 30, 40, 3, 3, 1); -- Below reorder level
    APP_ADMIN.INSERT_PRODUCT(4, 'Brown Rice', 'Nutritious brown rice', 80.00, 400, 80, 1, 1, 2);
    APP_ADMIN.INSERT_PRODUCT(5, 'Semolina', 'Fine wheat semolina', 40.00, 250, 40, 2, 2, 2);
    APP_ADMIN.INSERT_PRODUCT(6, 'Green Tea', 'Refreshing green tea', 65.00, 150, 30, 3, 3, 2);
    APP_ADMIN.INSERT_PRODUCT(7, 'Jasmine Rice', 'Fragrant jasmine rice', 110.00, 350, 70, 1, 1, 3);
    APP_ADMIN.INSERT_PRODUCT(8, 'Chickpea Flour', 'Gluten-free chickpea flour', 55.00, 200, 40, 2, 2, 3);
    APP_ADMIN.INSERT_PRODUCT(9, 'Earl Grey Tea', 'Classic Earl Grey blend', 70.00, 180, 35, 3, 3, 3);
END;
/

-- Insert reorder requests
BEGIN
    APP_ADMIN.INSERT_REORDER_REQUEST(1, 200, TO_DATE('2024-07-15', 'YYYY-MM-DD'), TO_DATE('2024-07-22', 'YYYY-MM-DD'), TO_DATE('2024-07-24', 'YYYY-MM-DD'), 'Pending', 1, 1, 1);
    APP_ADMIN.INSERT_REORDER_REQUEST(2, 150, TO_DATE('2024-07-16', 'YYYY-MM-DD'), TO_DATE('2024-07-23', 'YYYY-MM-DD'), TO_DATE('2024-07-27', 'YYYY-MM-DD'), 'Approved', 2, 2, 2);
    APP_ADMIN.INSERT_REORDER_REQUEST(3, 100, TO_DATE('2024-07-17', 'YYYY-MM-DD'), TO_DATE('2024-07-24', 'YYYY-MM-DD'), TO_DATE('2024-07-29', 'YYYY-MM-DD'), 'Delivered', 3, 3, 3);
    
END;
/



