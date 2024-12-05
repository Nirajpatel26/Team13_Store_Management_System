SET SERVEROUTPUT ON;

-- Block to kill any active session for APP_ADMIN user, if present
DECLARE
    v_sid NUMBER;
    v_serial NUMBER;
BEGIN
    SELECT SID, SERIAL# INTO v_sid, v_serial
    FROM V$SESSION
    WHERE USERNAME = 'APP_ADMIN' AND ROWNUM = 1;

    EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION ''' || v_sid || ',' || v_serial || ''' IMMEDIATE';
    DBMS_OUTPUT.PUT_LINE('Terminated existing session for APP_ADMIN.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No active session found for APP_ADMIN.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error terminating session: ' || SQLERRM);
END;
/

-- Block to drop APP_ADMIN user if it already exists
DECLARE
    v_user_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_user_count FROM ALL_USERS WHERE USERNAME = 'APP_ADMIN';

    IF v_user_count > 0 THEN
        EXECUTE IMMEDIATE 'DROP USER APP_ADMIN CASCADE';
        DBMS_OUTPUT.PUT_LINE('Dropped existing user APP_ADMIN.');
    END IF;
EXCEPTION 
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error dropping user APP_ADMIN: ' || SQLERRM);
END;
/

-- Create APP_ADMIN user with essential privileges
BEGIN
    EXECUTE IMMEDIATE 'CREATE USER APP_ADMIN IDENTIFIED BY "Admin123456789"';

    -- Grant connect and session privileges
    EXECUTE IMMEDIATE 'GRANT CONNECT, CREATE SESSION TO APP_ADMIN WITH ADMIN OPTION';
    
    -- Grant the ability to drop users
    EXECUTE IMMEDIATE 'GRANT DROP USER TO APP_ADMIN WITH ADMIN OPTION';

    -- Grant the ability to create roles, users, tables, views, and procedures
    EXECUTE IMMEDIATE 'GRANT CREATE ROLE, CREATE USER, CREATE TABLE, CREATE VIEW, CREATE TRIGGER, CREATE PROCEDURE TO APP_ADMIN WITH ADMIN OPTION';

    -- Grant additional system privileges that might be needed
    EXECUTE IMMEDIATE 'GRANT CREATE ANY PROCEDURE, DROP ANY PROCEDURE TO APP_ADMIN WITH ADMIN OPTION';
    
    --Grant priveleges to sequence
     EXECUTE IMMEDIATE 'GRANT CREATE SEQUENCE TO APP_ADMIN ';

    -- Allocate unlimited quota on DATA tablespace
    EXECUTE IMMEDIATE 'ALTER USER APP_ADMIN QUOTA UNLIMITED ON DATA';

    DBMS_OUTPUT.PUT_LINE('User APP_ADMIN created and granted permissions successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error creating or granting permissions to APP_ADMIN: ' || SQLERRM);
END;
/
