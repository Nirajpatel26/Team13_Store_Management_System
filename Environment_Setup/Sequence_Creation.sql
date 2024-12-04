-- Enable DBMS_OUTPUT
SET SERVEROUTPUT ON;

-- Drop existing sequences if they exist and print a message
BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE order_id_seq';
  DBMS_OUTPUT.PUT_LINE('Dropped sequence: order_id_seq');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN
      RAISE;
    ELSE
      DBMS_OUTPUT.PUT_LINE('Sequence order_id_seq does not exist.');
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE order_detail_seq';
  DBMS_OUTPUT.PUT_LINE('Dropped sequence: order_detail_seq');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN
      RAISE;
    ELSE
      DBMS_OUTPUT.PUT_LINE('Sequence order_detail_seq does not exist.');
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE pay_method_seq';
  DBMS_OUTPUT.PUT_LINE('Dropped sequence: pay_method_seq');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN
      RAISE;
    ELSE
      DBMS_OUTPUT.PUT_LINE('Sequence pay_method_seq does not exist.');
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE sales_transaction_seq';
  DBMS_OUTPUT.PUT_LINE('Dropped sequence: sales_transaction_seq');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN
      RAISE;
    ELSE
      DBMS_OUTPUT.PUT_LINE('Sequence sales_transaction_seq does not exist.');
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE loyalty_program_seq';
  DBMS_OUTPUT.PUT_LINE('Dropped sequence: loyalty_program_seq');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN
      RAISE;
    ELSE
      DBMS_OUTPUT.PUT_LINE('Sequence loyalty_program_seq does not exist.');
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE reorder_request_seq';
  DBMS_OUTPUT.PUT_LINE('Dropped sequence: reorder_request_seq');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN
      RAISE;
    ELSE
      DBMS_OUTPUT.PUT_LINE('Sequence reorder_request_seq does not exist.');
    END IF;
END;
/

-- Create Sequences
CREATE SEQUENCE order_id_seq
    START WITH 7
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;
/

CREATE SEQUENCE order_detail_seq
    START WITH 18
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;
/

CREATE SEQUENCE pay_method_seq
    START WITH 7
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;
/

CREATE SEQUENCE sales_transaction_seq
    START WITH 7
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;
/

CREATE SEQUENCE loyalty_program_seq
    START WITH 1000
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;
/

CREATE SEQUENCE reorder_request_seq
    START WITH 4
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;
/