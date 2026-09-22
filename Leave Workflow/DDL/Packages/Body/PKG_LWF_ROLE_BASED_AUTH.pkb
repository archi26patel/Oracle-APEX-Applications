create or replace PACKAGE BODY PKG_LWF_ROLE_BASED_AUTH IS

   PROCEDURE post_authentication(
      P_username       IN  VARCHAR2,
      P_password       IN  VARCHAR2,
      P_APP_USER_NAME  OUT VARCHAR2,
      P_APP_USER_EMAIL  OUT VARCHAR2, 
      P_APP_USER_ID    OUT VARCHAR2,
      P_APP_ROLE_NAME  OUT VARCHAR2,
      P_APP_ROLE_ID    OUT VARCHAR2,
      P_APP_DEPARTMENT_ID    OUT VARCHAR2,
      P_APP_DEPARTMENT_NAME  OUT VARCHAR2
   ) IS
   BEGIN
      SELECT 
         U.USER_ID, 
         U.FULL_NAME,
         U.EMAIL,
         R.ROLE_NAME,
         U.ROLE_ID,
         U.DEPARTMENT_ID,
         D.DEPARTMENT_NAME
      INTO     
         P_APP_USER_ID,  
         P_APP_USER_NAME,
         P_APP_USER_EMAIL,
         P_APP_ROLE_NAME,   
         P_APP_ROLE_ID,
         P_APP_DEPARTMENT_ID,
         P_APP_DEPARTMENT_NAME
      FROM 
         LWF_USERS u
         LEFT JOIN LWF_ROLES R ON U.ROLE_ID = R.ROLE_ID
         LEFT JOIN LWF_DEPARTMENT D ON U.DEPARTMENT_ID = D.DEPARTMENT_ID
      WHERE 
         upper(u.EMAIL) = upper(P_username)
         AND U.PASSWORD = P_password
         AND ROWNUM = 1;

   END post_authentication;

   FUNCTION LWF_LOGIN (
      P_username  IN VARCHAR2,
      P_password  IN VARCHAR2
   ) RETURN BOOLEAN
   AS
      L_COUNT NUMBER;
   BEGIN
      SELECT COUNT(*) INTO L_COUNT 
      FROM 
         LWF_USERS u
      WHERE 
         upper(u.EMAIL) = upper(P_username)
         AND u.PASSWORD = P_password
         AND ROWNUM = 1;

      RETURN L_COUNT > 0;
   END LWF_LOGIN;

END PKG_LWF_ROLE_BASED_AUTH;
/