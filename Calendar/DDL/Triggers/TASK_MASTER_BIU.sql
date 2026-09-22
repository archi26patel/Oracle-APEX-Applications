create or replace TRIGGER "TASK_MASTER_BIU" before insert or update  
    on "TASK_MASTER"  
    for each row  
begin  
    if inserting then  
        :new.CREATED := GET_IST_SYSTIMESTAMP;  
        :new.CREATED_BY := coalesce(sys_context('APEX$SESSION','APP_USER'),user);  
    end if;  
    :new.UPDATED := GET_IST_SYSTIMESTAMP;  
    :new.UPDATED_BY := coalesce(sys_context('APEX$SESSION','APP_USER'),user);  
end TASK_MASTER_BIU;
/