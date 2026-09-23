create or replace PACKAGE BODY TA_PACKAGE AS

    FUNCTION GET_AGE (
        P_DOB IN DATE
    ) RETURN VARCHAR2
    IS
        L_YEARS  NUMBER;
        L_MONTHS NUMBER;
        L_DAYS   NUMBER;
        L_TEMP   DATE;
    BEGIN
        IF P_DOB IS NULL THEN
            RETURN NULL;
        END IF;

        -- Calculate Years
        L_YEARS := FLOOR(MONTHS_BETWEEN(TRUNC(SYSDATE), TRUNC(P_DOB)) / 12);

        -- Calculate Months
        L_MONTHS := FLOOR(
                        MONTHS_BETWEEN(
                            TRUNC(SYSDATE),
                            ADD_MONTHS(TRUNC(P_DOB), L_YEARS * 12)
                        )
                    );

        -- Calculate Remaining Days
        L_TEMP := ADD_MONTHS(TRUNC(P_DOB), (L_YEARS * 12) + L_MONTHS);

        L_DAYS := TRUNC(SYSDATE) - L_TEMP;

        RETURN L_YEARS || ' Years ' ||
               L_MONTHS || ' Months ' ||
               L_DAYS || ' Days';

    END GET_AGE;

END TA_PACKAGE;
/