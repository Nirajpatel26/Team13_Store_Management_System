-- Insert into loyalty_program
BEGIN
  APP_ADMIN.INSERT_LOYALTY_PROGRAM(1, 'Silver Member', 10, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-12-31', 'YYYY-MM-DD'));
  APP_ADMIN.INSERT_LOYALTY_PROGRAM(2, 'Gold Member', 20, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-12-31', 'YYYY-MM-DD'));
  APP_ADMIN.INSERT_LOYALTY_PROGRAM(3, 'Gold Member', 20, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-12-31', 'YYYY-MM-DD'));
  APP_ADMIN.INSERT_LOYALTY_PROGRAM(4, 'Silver Member', 10, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-12-31', 'YYYY-MM-DD'));
  APP_ADMIN.INSERT_LOYALTY_PROGRAM(5, 'Gold Member', 20, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-12-31', 'YYYY-MM-DD'));
  APP_ADMIN.INSERT_LOYALTY_PROGRAM(6, 'Gold Member', 20, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-12-31', 'YYYY-MM-DD'));
  APP_ADMIN.INSERT_LOYALTY_PROGRAM(7, 'Gold Member', 20, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-12-31', 'YYYY-MM-DD'));
END;
/

-- Insert into employee
BEGIN
  APP_ADMIN.INSERT_EMPLOYEE(1, 'Rajesh', 'Kumar', 'rajesh.kumar@gmail.com', 9876543210, '123 Main St, Mumbai', 'Manager', TO_DATE('2022-05-15', 'YYYY-MM-DD'), 75000.00);
  APP_ADMIN.INSERT_EMPLOYEE(2, 'Priya', 'Sharma', 'priya.sharma@yahoo.com', 9876543211, '456 Oak St, Delhi', 'Marketing Manager', TO_DATE('2022-06-01', 'YYYY-MM-DD'), 65000.00);
  APP_ADMIN.INSERT_EMPLOYEE(3, 'Amit', 'Patel', 'amit.patel@gmail.com', 9876543212, '789 Pine St, Bangalore', 'Inventory Manager ', TO_DATE('2022-07-01', 'YYYY-MM-DD'), 55000.00);
  APP_ADMIN.INSERT_EMPLOYEE(4, 'Sneha', 'Gupta', 'sneha.gupta@yahoo.com', 9876543213, '101 Elm St, Chennai', 'Cashier', TO_DATE('2022-08-01', 'YYYY-MM-DD'), 45000.00);
  APP_ADMIN.INSERT_EMPLOYEE(5, 'Vikram', 'Singh', 'vikram.singh@outlook.com', 9876543214, '202 Maple St, Kolkata', 'Cashier', TO_DATE('2022-09-01', 'YYYY-MM-DD'), 50000.00);
END;
/





