create or replace TRIGGER "TA_MEETINGS_BIU" 
    before insert or update 
    on TA_MEETINGS 
    for each row 
begin 
    if inserting then 
        :new.CREATED_ON := sysdate; 
        :new.CREATED_BY := coalesce(sys_context('APEX$SESSION','APP_USER'),user); 
    end if; 
end TA_MEETINGS_BIU;
/