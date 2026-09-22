create or replace PACKAGE  PKG_LWF_ROLE_BASED_AUTH IS
 
    PROCEDURE post_authentication(P_username       IN  VARCHAR2,
      P_password       IN  VARCHAR2,
      P_APP_USER_NAME  OUT VARCHAR2,
      P_APP_USER_EMAIL  OUT VARCHAR2, 
      P_APP_USER_ID    OUT VARCHAR2,
      P_APP_ROLE_NAME  OUT VARCHAR2,
      P_APP_ROLE_ID    OUT VARCHAR2,
      P_APP_DEPARTMENT_ID    OUT VARCHAR2,
      P_APP_DEPARTMENT_NAME  OUT VARCHAR2
                                 );
 
    FUNCTION LWF_LOGIN (
                        P_username          IN  VARCHAR2,
                        P_password         IN  VARCHAR2
                        )
    RETURN BOOLEAN ;
 
END PKG_LWF_ROLE_BASED_AUTH;
/