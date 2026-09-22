create or replace PACKAGE BODY PKG_LWF_LEAVE_APEX_TASKS IS
 
  PROCEDURE INSERT_LWF_LEAVE_APEX_TASKS(P_LEAVE_ID  IN  NUMBER,
                                 P_APPROVAL_LEVEL   IN  NUMBER,
                                 P_TASK_ID IN NUMBER
    ) AS
        v_leave_row LWF_LEAVES%ROWTYPE;
        v_task_row APEX_TASKS%ROWTYPE;
    BEGIN
        BEGIN
            SELECT * INTO v_leave_row FROM LWF_LEAVES
            WHERE LEAVE_ID = P_LEAVE_ID;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN 
                v_leave_row := NULL;
        END;

        BEGIN
            SELECT * INTO v_task_row FROM APEX_TASKS
            WHERE TASK_ID = P_TASK_ID;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN 
                v_task_row := NULL;
        END;

        INSERT INTO LWF_LEAVE_APEX_TASKS (
            TASK_ID , 
	        WORKSPACE_ID , 
	        WORKFLOW_ID , 
	        WORKSPACE , 
	        WORKSPACE_DISPLAY_NAME , 
	        APPLICATION_ID , 
	        APPLICATION_NAME , 
	        WORKING_COPY_NAME , 
	        TASK_DEF_ID , 
	        TASK_DEF_NAME , 
	        TASK_DEF_STATIC_ID , 
	        PREVIOUS_TASK_ID , 
	        SUBJECT , 
	        TASK_TYPE_CODE , 
	        TASK_TYPE , 
	        DUE_ON, 
	        PRIORITY , 
	        PRIORITY_LEVEL , 
	        DETAIL_PK , 
	        INITIATOR , 
	        INITIATOR_CAN_COMPLETE , 
	        ACTUAL_OWNER , 
	        PREVIOUS_OWNER , 
	        STATE_CODE , 
	        STATE , 
	        RENEWAL_COUNT , 
	        OUTCOME_CODE , 
	        OUTCOME , 
	        AT_CREATED_BY , 
	        AT_CREATED_ON , 
	        AT_LAST_UPDATED_BY , 
	        AT_LAST_UPDATED_ON , 
	        LEAVE_ID , 
	        USER_ID , 
	        LEAVE_TYPE_ID , 
	        FROM_DATE , 
	        TO_DATE , 
	        REASON , 
	        LEAVE_DAYS , 
	        STATUS , 
	        APPROVED_BY , 
	        APPROVED_AT  , 
	        APPROVAL_REASON , 
	        REJECTED_BY , 
	        REJECTED_AT  , 
	        REJECTION_REASON , 
	        L_TASK_ID , 
	        L_WORKFLOW_ID , 
	        APPROVAL_LEVEL , 
	        L_CREATED_AT  , 
	        L_CREATED_BY , 
	        L_UPDATED_AT  , 
	        L_UPDATED_BY
        ) VALUES(
            v_task_row.TASK_ID , 
	        v_task_row.WORKSPACE_ID , 
	        v_task_row.WORKFLOW_ID , 
	        v_task_row.WORKSPACE , 
	        v_task_row.WORKSPACE_DISPLAY_NAME , 
	        v_task_row.APPLICATION_ID , 
	        v_task_row.APPLICATION_NAME , 
	        v_task_row.WORKING_COPY_NAME , 
	        v_task_row.TASK_DEF_ID , 
	        v_task_row.TASK_DEF_NAME , 
	        v_task_row.TASK_DEF_STATIC_ID , 
	        v_task_row.PREVIOUS_TASK_ID , 
	        v_task_row.SUBJECT , 
	        v_task_row.TASK_TYPE_CODE , 
	        v_task_row.TASK_TYPE , 
	        v_task_row.DUE_ON, 
	        v_task_row.PRIORITY , 
	        v_task_row.PRIORITY_LEVEL , 
	        v_task_row.DETAIL_PK , 
	        v_task_row.INITIATOR , 
	        v_task_row.INITIATOR_CAN_COMPLETE , 
	        v_task_row.ACTUAL_OWNER , 
	        v_task_row.PREVIOUS_OWNER , 
	        v_task_row.STATE_CODE , 
	        v_task_row.STATE , 
	        v_task_row.RENEWAL_COUNT , 
	        v_task_row.OUTCOME_CODE , 
	        v_task_row.OUTCOME , 
	        v_task_row.CREATED_BY , 
	        v_task_row.CREATED_ON , 
	        v_task_row.LAST_UPDATED_BY , 
	        v_task_row.LAST_UPDATED_ON , 
	        v_leave_row.LEAVE_ID , 
	        v_leave_row.USER_ID , 
	        v_leave_row.LEAVE_TYPE_ID , 
	        v_leave_row.FROM_DATE , 
	        v_leave_row.TO_DATE , 
	        v_leave_row.REASON , 
	        v_leave_row.LEAVE_DAYS , 
	        v_leave_row.STATUS , 
	        v_leave_row.APPROVED_BY , 
	        v_leave_row.APPROVED_AT  , 
	        v_leave_row.APPROVAL_REASON , 
	        v_leave_row.REJECTED_BY , 
	        v_leave_row.REJECTED_AT  , 
	        v_leave_row.REJECTION_REASON , 
	        v_task_row.TASK_ID , 
	        v_task_row.WORKFLOW_ID , 
	        P_APPROVAL_LEVEL , 
	        v_leave_row.CREATED_AT  , 
	        v_leave_row.CREATED_BY , 
	        v_leave_row.UPDATED_AT  , 
	        v_leave_row.UPDATED_BY
        );
    END;
                                

  PROCEDURE UPDATE_LWF_LEAVE_APEX_TASKS(P_LEAVE_ID  IN  NUMBER,
                                 P_APPROVAL_LEVEL   IN  NUMBER,
                                 P_TASK_ID IN NUMBER
    )AS
        v_leave_row LWF_LEAVES%ROWTYPE;
        v_task_row APEX_TASKS%ROWTYPE;
    BEGIN
        BEGIN
            SELECT * INTO v_leave_row FROM LWF_LEAVES
            WHERE LEAVE_ID = P_LEAVE_ID;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN 
                v_leave_row := NULL;
        END;

        BEGIN
            SELECT * INTO v_task_row FROM APEX_TASKS
            WHERE TASK_ID = P_TASK_ID;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN 
                v_task_row := NULL;
        END;

        UPDATE LWF_LEAVE_APEX_TASKS
        SET 
	        WORKSPACE_ID = v_task_row.WORKSPACE_ID, 
	        WORKFLOW_ID = v_task_row.WORKFLOW_ID , 
	        WORKSPACE = v_task_row.WORKSPACE, 
	        WORKSPACE_DISPLAY_NAME = v_task_row.WORKSPACE_DISPLAY_NAME, 
	        APPLICATION_ID = v_task_row.APPLICATION_ID, 
	        APPLICATION_NAME = v_task_row.APPLICATION_NAME, 
	        WORKING_COPY_NAME = v_task_row.WORKING_COPY_NAME, 
	        TASK_DEF_ID = v_task_row.TASK_DEF_ID, 
	        TASK_DEF_NAME = v_task_row.TASK_DEF_NAME, 
	        TASK_DEF_STATIC_ID = v_task_row.TASK_DEF_STATIC_ID, 
	        PREVIOUS_TASK_ID = v_task_row.PREVIOUS_TASK_ID, 
	        SUBJECT = v_task_row.SUBJECT, 
	        TASK_TYPE_CODE = v_task_row.TASK_TYPE_CODE, 
	        TASK_TYPE = v_task_row.TASK_TYPE, 
	        DUE_ON = v_task_row.DUE_ON, 
	        PRIORITY = v_task_row.PRIORITY, 
	        PRIORITY_LEVEL = v_task_row.PRIORITY_LEVEL, 
	        DETAIL_PK = v_task_row.DETAIL_PK, 
	        INITIATOR = v_task_row.INITIATOR, 
	        INITIATOR_CAN_COMPLETE = v_task_row.INITIATOR_CAN_COMPLETE, 
	        ACTUAL_OWNER = v_task_row.ACTUAL_OWNER, 
	        PREVIOUS_OWNER = v_task_row.PREVIOUS_OWNER, 
	        STATE_CODE = v_task_row.STATE_CODE, 
	        STATE = v_task_row.STATE, 
	        RENEWAL_COUNT = v_task_row.RENEWAL_COUNT, 
	        OUTCOME_CODE = v_task_row.OUTCOME_CODE, 
	        OUTCOME = v_task_row.OUTCOME, 
	        AT_CREATED_BY = v_task_row.CREATED_BY, 
	        AT_CREATED_ON = v_task_row.CREATED_ON, 
	        AT_LAST_UPDATED_BY = v_task_row.LAST_UPDATED_BY, 
	        AT_LAST_UPDATED_ON = v_task_row.LAST_UPDATED_ON, 
	        LEAVE_TYPE_ID = v_leave_row.LEAVE_TYPE_ID, 
	        FROM_DATE = v_leave_row.FROM_DATE, 
	        TO_DATE = v_leave_row.TO_DATE, 
	        REASON = v_leave_row.REASON, 
	        LEAVE_DAYS = v_leave_row.LEAVE_DAYS, 
	        STATUS = v_leave_row.STATUS, 
	        APPROVED_BY = v_leave_row.APPROVED_BY, 
	        APPROVED_AT = v_leave_row.APPROVED_AT, 
	        APPROVAL_REASON = v_leave_row.APPROVAL_REASON, 
	        REJECTED_BY = v_leave_row.REJECTED_BY, 
	        REJECTED_AT = v_leave_row.REJECTED_AT, 
	        REJECTION_REASON = v_leave_row.REJECTION_REASON, 
	        L_TASK_ID = v_task_row.TASK_ID, 
	        L_WORKFLOW_ID = v_task_row.WORKFLOW_ID, 
	        APPROVAL_LEVEL = P_APPROVAL_LEVEL, 
	        L_CREATED_AT = v_leave_row.CREATED_AT, 
	        L_CREATED_BY = v_leave_row.CREATED_BY, 
	        L_UPDATED_AT = v_leave_row.UPDATED_AT, 
	        L_UPDATED_BY = v_leave_row.UPDATED_BY
        WHERE TASK_ID = P_TASK_ID;
    END;
 
END PKG_LWF_LEAVE_APEX_TASKS;
/