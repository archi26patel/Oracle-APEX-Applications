create or replace TRIGGER TRG_LWT_SYNC
AFTER INSERT OR UPDATE OR DELETE ON LWF_LEAVE_TYPE
FOR EACH ROW
BEGIN

    -- ▶▶ INSERT: New leave type added → create leave balance for ALL existing users
    IF INSERTING THEN
        INSERT INTO LWF_LEAVES_TAKEN (
            LEAVE_TYPE_ID,
            USER_ID,
            TOTAL_ALLOCATED_LEAVE,
            USED_LEAVES,
            AVAILABLE_LEAVES,
            YEAR
        )
        SELECT
            :NEW.LEAVE_ID,
            U.USER_ID,
            :NEW.TOTAL_ALLOCATED_LEAVES,
            0,
            :NEW.TOTAL_ALLOCATED_LEAVES,
            EXTRACT(YEAR FROM SYSDATE)
        FROM LWF_USERS U;

    -- ▶▶ UPDATE: Leave type modified → sync all user balances
    ELSIF UPDATING THEN
        UPDATE LWF_LEAVES_TAKEN
        SET
            TOTAL_ALLOCATED_LEAVE = :NEW.TOTAL_ALLOCATED_LEAVES,
            AVAILABLE_LEAVES      = :NEW.TOTAL_ALLOCATED_LEAVES - USED_LEAVES
        WHERE LEAVE_TYPE_ID = :OLD.LEAVE_ID;

    -- ▶▶ DELETE: Leave type removed → remove all user balance records
    ELSIF DELETING THEN
        DELETE FROM LWF_LEAVES_TAKEN
        WHERE LEAVE_TYPE_ID = :OLD.LEAVE_ID;

    END IF;

END;
/