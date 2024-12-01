

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
    START WITH 3
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;
/