create or replace PACKAGE BODY PKG_DEMO_CUSTOM_AUTH IS

    PROCEDURE POST_AUTHENTICATION (
        P_USERNAME                   IN  VARCHAR2,
        P_PASSWORD                   IN  VARCHAR2,
        P_APP_USER_ID                OUT VARCHAR2,
        P_APP_USERNAME               OUT VARCHAR2,
        P_APP_USER_EMAIL             OUT VARCHAR2,
        P_APP_ROLE_ID                OUT VARCHAR2,
        P_APP_ROLE_NAME              OUT VARCHAR2,
        P_APP_ROLE_HOME_PAGE_APEX_ID OUT NUMBER
    ) IS
    BEGIN
        SELECT 
            TO_CHAR(U.USER_ID),
            TRIM(U.FIRST_NAME || ' ' || U.LAST_NAME),
            U.EMAIL,
            TO_CHAR(R.ROLE_ID),
            R.ROLE_NAME,
            PM.APEX_PAGE_ID
        INTO 
            P_APP_USER_ID,
            P_APP_USERNAME,
            P_APP_USER_EMAIL,
            P_APP_ROLE_ID,
            P_APP_ROLE_NAME,
            P_APP_ROLE_HOME_PAGE_APEX_ID
        FROM DEMO_USER_MASTER U
        JOIN DEMO_USER_ROLE_ACCESS_MASTER URA 
            ON U.USER_ID = URA.USER_ID 
           AND URA.IS_ACTIVE = 'Y'
        JOIN DEMO_ROLE_MASTER R 
            ON URA.ROLE_ID = R.ROLE_ID 
           AND R.IS_ACTIVE = 'Y'
        LEFT JOIN DEMO_ROLE_HOME_PAGES RHP 
            ON R.ROLE_ID = RHP.ROLE_ID 
           AND RHP.IS_ACTIVE = 'Y'
        LEFT JOIN DEMO_PAGE_MASTER PM 
            ON RHP.HOME_PAGE_ID = PM.PAGE_ID 
           AND PM.IS_ACTIVE = 'Y'
        WHERE UPPER(TRIM(U.EMAIL)) = UPPER(TRIM(P_USERNAME))
          AND U.IS_ACTIVE = 'Y'
        ORDER BY NVL(R.ROLE_PRIORITY, 999999) ASC, R.ROLE_ID ASC
        FETCH FIRST 1 ROWS ONLY;

        -- UPDATE LAST LOGIN TIME
        UPDATE DEMO_USER_MASTER
        SET LAST_LOGIN = GET_IST_SYSTIMESTAMP
        WHERE UPPER(TRIM(EMAIL)) = UPPER(TRIM(P_USERNAME));
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_APP_USER_ID                := NULL;
            P_APP_USERNAME               := NULL;
            P_APP_USER_EMAIL             := NULL;
            P_APP_ROLE_ID                := NULL;
            P_APP_ROLE_NAME              := NULL;
            P_APP_ROLE_HOME_PAGE_APEX_ID := NULL;
        WHEN OTHERS THEN
            RAISE;
    END POST_AUTHENTICATION;

    FUNCTION CUSTOM_LOGIN (
        P_USERNAME                   IN  VARCHAR2,
        P_PASSWORD                   IN  VARCHAR2
    ) RETURN BOOLEAN 
    IS
        L_COUNT NUMBER := 0;
    BEGIN
        SELECT COUNT(1)
        INTO L_COUNT  
        FROM DEMO_USER_MASTER U
        JOIN DEMO_USER_ROLE_ACCESS_MASTER URA 
            ON U.USER_ID = URA.USER_ID 
           AND URA.IS_ACTIVE = 'Y'
        JOIN DEMO_ROLE_MASTER R 
            ON URA.ROLE_ID = R.ROLE_ID 
           AND R.IS_ACTIVE = 'Y'
        WHERE UPPER(TRIM(U.EMAIL)) = UPPER(TRIM(P_USERNAME))
          AND U.PASSWORD = DEMO_GET_USER_PASSWORD_HASH(P_USERNAME, P_PASSWORD)
          AND U.IS_ACTIVE = 'Y';

        RETURN (L_COUNT > 0);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END CUSTOM_LOGIN;

END PKG_DEMO_CUSTOM_AUTH;
/