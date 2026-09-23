create or replace TRIGGER "XXPI_ROLES_BIU" 
BEFORE INSERT OR UPDATE 
ON "XXPI_ROLES" 
FOR EACH ROW 
BEGIN 
    IF INSERTING THEN 
        :NEW.CREATED_AT := GET_IST_SYSTIMESTAMP; 
        :NEW.CREATED_BY := 
            COALESCE( 
                SYS_CONTEXT('APEX$SESSION','APP_USER'), 
                USER 
            ); 
    END IF; 
 
    :NEW.UPDATED_AT := GET_IST_SYSTIMESTAMP; 
    :NEW.UPDATED_BY := 
        COALESCE( 
            SYS_CONTEXT('APEX$SESSION','APP_USER'), 
            USER 
        ); 
END XXPI_ROLES_BIU;
/