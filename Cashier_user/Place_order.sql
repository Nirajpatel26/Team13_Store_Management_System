SET SERVEROUTPUT ON;
BEGIN
    APP_ADMIN.add_order(
        p_customer_email => 'riya.sharma@example.com',
        p_order_date => SYSDATE,
        p_pay_type => 'Credit Card',
        p_order_details => SYS.ODCIVARCHAR2LIST('7,10', '8,190'),  -- product_id,quantity
        p_employee_id => 4
    );
END;
/