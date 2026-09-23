create or replace FUNCTION get_ist_systimestamp
   RETURN TIMESTAMP
IS
BEGIN
   RETURN CAST(
            SYSTIMESTAMP AT TIME ZONE 'Asia/Calcutta'
          AS TIMESTAMP);
END;
/