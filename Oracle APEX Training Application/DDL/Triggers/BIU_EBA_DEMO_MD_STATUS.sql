create or replace TRIGGER "BIU_EBA_DEMO_MD_STATUS" 
    before insert or update on eba_demo_md_status
    for each row
begin
    if inserting then
        :new.created    := current_timestamp;
        :new.created_by := nvl(wwv_flow.g_user,user);
    end if;
    :new.cd         := upper(:new.cd);
    :new.updated    := current_timestamp;
    :new.updated_by := nvl(wwv_flow.g_user,user);
end;
/