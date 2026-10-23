create or replace PACKAGE PKG_DEMO_CUSTOM_AUTH IS

    PROCEDURE POST_AUTHENTICATION (
        P_USERNAME                   IN  VARCHAR2,
        P_PASSWORD                   IN  VARCHAR2,
        P_APP_USER_ID                OUT VARCHAR2,
        P_APP_USERNAME               OUT VARCHAR2,
        P_APP_USER_EMAIL             OUT VARCHAR2,
        P_APP_ROLE_ID                OUT VARCHAR2,
        P_APP_ROLE_NAME              OUT VARCHAR2,
        P_APP_ROLE_HOME_PAGE_APEX_ID OUT NUMBER
    );

    FUNCTION CUSTOM_LOGIN (
        P_USERNAME                   IN  VARCHAR2,
        P_PASSWORD                   IN  VARCHAR2
    ) RETURN BOOLEAN;

END PKG_DEMO_CUSTOM_AUTH;
/