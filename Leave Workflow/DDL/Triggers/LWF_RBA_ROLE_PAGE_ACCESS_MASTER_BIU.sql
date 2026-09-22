create or replace TRIGGER "LWF_RBA_ROLE_PAGE_ACCESS_MASTER_BIU" 
    before insert or update 
    on LWF_ROLE_PAGE_ACCESS_MASTER 
    for each row 
begin 
    if inserting then 
        :new.CREATED_AT := sysdate; 
        :new.CREATED_BY := coalesce(sys_context('APEX$SESSION','APP_USER'),user); 
    end if; 
    :new.UPDATED_AT := sysdate; 
    :new.UPDATED_BY := coalesce(sys_context('APEX$SESSION','APP_USER'),user); 
end LWF_RBA_ROLE_PAGE_ACCESS_MASTER_BIU;
/