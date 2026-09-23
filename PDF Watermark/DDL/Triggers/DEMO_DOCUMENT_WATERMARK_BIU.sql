create or replace TRIGGER "DEMO_DOCUMENT_WATERMARK_BIU" 
    before insert or update 
    on DEMO_DOCUMENT_WATERMARK 
    for each row 
begin 
    if inserting then 
        :new.CREATED_ON := sysdate; 
        :new.CREATED_BY := coalesce(sys_context('APEX$SESSION','APP_USER'),user); 
    end if; 
    :new.UPDATED_ON := sysdate; 
    :new.UPDATED_BY := coalesce(sys_context('APEX$SESSION','APP_USER'),user); 
end DEMO_DOCUMENT_WATERMARK_BIU;
/