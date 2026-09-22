create or replace PACKAGE  PKG_LWF_LEAVE_APEX_TASKS IS
 
  PROCEDURE INSERT_LWF_LEAVE_APEX_TASKS(P_LEAVE_ID  IN  NUMBER,
                                 P_APPROVAL_LEVEL   IN  NUMBER,
                                 P_TASK_ID IN NUMBER
                                 );

  PROCEDURE UPDATE_LWF_LEAVE_APEX_TASKS(P_LEAVE_ID  IN  NUMBER,
                                 P_APPROVAL_LEVEL   IN  NUMBER,
                                 P_TASK_ID IN NUMBER
                                 );
 
END PKG_LWF_LEAVE_APEX_TASKS;
/