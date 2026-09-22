create or replace TRIGGER "XXEH_RAISE_ERROR_MESSAGES_BIU" before insert or update  
    on "XXEH_RAISE_ERROR_MESSAGES"  
    for each row  
begin  
    if inserting then  
        :new.CREATED_AT := GET_IST_SYSTIMESTAMP;  
        :new.CREATED_BY := coalesce(sys_context('APEX$SESSION','APP_USER'),user);  
    end if;  
    :new.UPDATED_AT := GET_IST_SYSTIMESTAMP;  
    :new.UPDATED_BY := coalesce(sys_context('APEX$SESSION','APP_USER'),user);  
end XXEH_RAISE_ERROR_MESSAGES_BIU;
/