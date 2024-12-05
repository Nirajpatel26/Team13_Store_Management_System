SET SERVEROUTPUT ON;

EXEC APP_ADMIN.generate_sales_report(p_start_date => TO_DATE('2024-01-01', 'YYYY-MM-DD'), p_end_date => TO_DATE('2024-12-31', 'YYYY-MM-DD'));