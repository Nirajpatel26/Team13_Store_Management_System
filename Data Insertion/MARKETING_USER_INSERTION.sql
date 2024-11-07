BEGIN
    APP_ADMIN.INSERT_MARKETING(1, 'Diwali Special Offer!', 'Email', TO_DATE('2024-10-15', 'YYYY-MM-DD'), 15.00, 1);
    APP_ADMIN.INSERT_MARKETING(2, 'Holi Discount Bonanza', 'SMS', TO_DATE('2024-03-01', 'YYYY-MM-DD'), 10.00, 2);
    APP_ADMIN.INSERT_MARKETING(3, 'Summer Sale Extravaganza', 'Social Media', TO_DATE('2024-05-01', 'YYYY-MM-DD'), 20.00, 3);
    APP_ADMIN.INSERT_MARKETING(4, 'Monsoon Madness Deals', 'Push Notification', TO_DATE('2024-07-01', 'YYYY-MM-DD'), 12.50, 4);
    APP_ADMIN.INSERT_MARKETING(5, 'New Year New Savings', 'Email', TO_DATE('2024-12-26', 'YYYY-MM-DD'), 18.00, 5);
END;
/




