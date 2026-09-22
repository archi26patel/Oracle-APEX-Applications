create or replace TRIGGER trg_lwf_users_fullname_usercode
BEFORE INSERT OR UPDATE ON LWF_USERS
FOR EACH ROW
DECLARE
    v_role_code LWF_ROLES.ROLE_CODE%TYPE;
BEGIN
    -- FULL NAME
    :NEW.FULL_NAME := :NEW.FIRST_NAME || ' ' || :NEW.LAST_NAME;

    -- USER CODE (ONLY ON INSERT)
    IF INSERTING THEN
        -- role_code fetch karo
        SELECT ROLE_CODE
        INTO v_role_code
        FROM LWF_ROLES
        WHERE ROLE_ID = :NEW.ROLE_ID;

        -- usercode generate (EMP0001 type)
        :NEW.USERCODE := UPPER(v_role_code) || LPAD(:NEW.USER_ID, 4, '0');
    END IF;

END;
/