create or replace PACKAGE BODY apex_pkg_face_security AS

/**
 * ============================================================================
 * PACKAGE BODY  : APEX_PKG_FACE_SECURITY
 * PURPOSE       : Implements secure cryptographic operations, session-independent
 *                 hashing, single-use biometric nonce lifecycle, and dual-mode
 *                 authentication (Password & Face) for Oracle APEX.
 *
 * HOW IT WORKS  :
 * 1. apex_hash_pwd:
 *    - Combines a static schema salt, uppercase username, and user password.
 *    - Evaluates SHA-256 via Oracle's native `STANDARD_HASH` function.
 *    - Eliminates dynamic session dependencies, ensuring persistent matching.
 *
 * 2. apex_set_user_password:
 *    - Invokes `apex_hash_pwd` to compute the 64-character hexadecimal hash.
 *    - Stores the hash, clears lock flags (`apex_is_locked = 'N'`), and resets
 *      failed login attempt counters to 0.
 *
 * 3. apex_gen_face_token:
 *    - Generates a random cryptographic nonce string prefixed with `APEX_BIO_`.
 *    - Sets a 3-minute expiration window using `GET_IST_SYSTIMESTAMP + (3 / 1440)`.
 *    - Persists the single-use token on the target user record.
 *
 * 4. apex_authenticate_user:
 *    - Evaluates if the user account is locked (`apex_is_locked = 'Y'`).
 *    - Case A (Biometric Token Login): Verifies if token starts with `APEX_BIO_`,
 *      matches `apex_auth_token`, and is within the 3-minute validity window.
 *      Immediately wipes `apex_auth_token` and `apex_token_expiry` to enforce single-use.
 *    - Case B (Standard Password Login): Computes deterministic SHA-256 hash
 *      of entered credentials and compares against `apex_pwd_hash`.
 *    - Increments `apex_failed_count` on bad passwords and automatically sets
 *      `apex_is_locked = 'Y'` upon reaching 8 failed attempts.
 *
 * ARCHITECTURAL CONFIGURATION (GLOBAL CONSTANTS):
 * - gc_max_failed_attempts        : Threshold limit for consecutive invalid logins.
 * - gc_token_expiry_minutes       : Validity window (in minutes) for biometric tokens.
 * - gc_lockout_duration_minutes   : Duration (in minutes) for which an account stays locked.
 *
 * TIME-BASED AUTO UNLOCK:
 * - When failed attempts hit gc_max_failed_attempts, the account is locked and 
 *   apex_locked_until is set using: GET_IST_SYSTIMESTAMP + (gc_lockout_duration_minutes / 1440).
 * - On subsequent attempts, if GET_IST_SYSTIMESTAMP >= apex_locked_until, the system
 *   automatically resets the lock flags and allows normal authentication.
 * ============================================================================
 */

    -- ========================================================================
    -- GLOBAL SECURITY CONFIGURATION CONSTANTS
    -- ========================================================================
    
    -- 1. Maximum allowed invalid password attempts before account lockout
    gc_max_failed_attempts      CONSTANT NUMBER := 5;

    -- 2. Validity window for temporary biometric tokens (in minutes)
    gc_token_expiry_minutes     CONSTANT NUMBER := 3;

    -- 3. Account lockout penalty duration before auto-unlock (in minutes)
    gc_lockout_duration_minutes CONSTANT NUMBER := 15;


    -- ========================================================================
    -- 1. DETERMINISTIC CRYPTOGRAPHIC SHA-256 HASH GENERATOR
    -- ========================================================================
    FUNCTION apex_hash_pwd(
        p_username IN VARCHAR2,
        p_password IN VARCHAR2
    ) RETURN VARCHAR2 IS
        l_hash VARCHAR2(64);
    BEGIN
        -- Execute STANDARD_HASH through SQL context to prevent DBA grant requirements
        -- Static schema salt guarantees identical hash irrespective of active session ID
        SELECT standard_hash(
                   'SALT_APEX_2026#' || UPPER(TRIM(p_username)) || '#' || TRIM(p_password),
                   'SHA256'
               )
          INTO l_hash
          FROM dual;

        RETURN l_hash;
    END apex_hash_pwd;

    -- ========================================================================
    -- 2. CREDENTIAL ENROLLMENT & PASSWORD SETTER
    -- ========================================================================
    PROCEDURE apex_set_user_password(
        p_username IN VARCHAR2,
        p_password IN VARCHAR2
    ) IS
        l_clean_uname   VARCHAR2(100);
        l_computed_hash VARCHAR2(64);
    BEGIN
        -- Standardize username to uppercase and trimmed string
        l_clean_uname   := UPPER(TRIM(p_username));
        l_computed_hash := apex_hash_pwd(l_clean_uname, p_password);

        -- Persist hash and unlock account if previously restricted
        UPDATE apex_face_users
           SET apex_pwd_hash      = l_computed_hash,
               apex_failed_count  = 0,
               apex_is_locked     = 'N',
               apex_locked_until  = NULL
         WHERE UPPER(TRIM(apex_username)) = l_clean_uname;
    END apex_set_user_password;

    -- ========================================================================
    -- 3. SINGLE-USE BIOMETRIC NONCE TOKEN GENERATOR
    -- ========================================================================
    FUNCTION apex_gen_face_token(
        p_username IN VARCHAR2
    ) RETURN VARCHAR2 IS
        l_token       VARCHAR2(128);
        l_clean_uname VARCHAR2(100);
        l_user        apex_face_users%ROWTYPE;
    BEGIN
        l_clean_uname := UPPER(TRIM(p_username));
        
        -- Retrieve user record to verify account status
        SELECT * INTO l_user
          FROM apex_face_users
         WHERE UPPER(TRIM(apex_username)) = l_clean_uname;

        -- Auto-Unlock Evaluation: Check if lockout period has expired
        IF NVL(l_user.apex_is_locked, 'N') = 'Y' THEN
            IF l_user.apex_locked_until IS NOT NULL 
               AND GET_IST_SYSTIMESTAMP >= l_user.apex_locked_until THEN
                
                -- Lockout expired: Reset lock flags and counters
                UPDATE apex_face_users
                   SET apex_is_locked     = 'N',
                       apex_failed_count  = 0,
                       apex_locked_until  = NULL
                 WHERE apex_user_id = l_user.apex_user_id;
            ELSE
                -- Lockout still active: Prevent token generation
                RETURN NULL;
            END IF;
        END IF;

        -- Generate unique, cryptographically random single-use nonce token
        l_token := 'APEX_BIO_' || sys_guid() || '_' || dbms_random.string('x', 16);

        -- Assign token with expiration calculated using gc_token_expiry_minutes
        UPDATE apex_face_users
           SET apex_auth_token    = l_token,
               apex_token_expiry  = GET_IST_SYSTIMESTAMP + (gc_token_expiry_minutes / 1440),
               apex_failed_count  = 0,
               apex_is_locked     = 'N',
               apex_locked_until  = NULL
         WHERE UPPER(TRIM(apex_username)) = l_clean_uname;

        RETURN l_token;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END apex_gen_face_token;

    -- ========================================================================
    -- 4. HYBRID APEX AUTHENTICATION SCHEME FUNCTION
    -- ========================================================================
    FUNCTION apex_authenticate_user(
        p_username IN VARCHAR2,
        p_password IN VARCHAR2
    ) RETURN BOOLEAN IS
        l_user          apex_face_users%ROWTYPE;
        l_clean_uname   VARCHAR2(100);
        l_computed_hash VARCHAR2(64);
        l_unlock_time   VARCHAR2(30);
    BEGIN
        l_clean_uname := UPPER(TRIM(p_username));

        -- Retrieve user security profile
        SELECT * INTO l_user
          FROM apex_face_users
         WHERE UPPER(TRIM(apex_username)) = l_clean_uname;

        -- --------------------------------------------------------------------
        -- LOCKOUT VALIDATION & AUTOMATIC TIME-BASED UNLOCK
        -- --------------------------------------------------------------------
        IF NVL(l_user.apex_is_locked, 'N') = 'Y' THEN
            -- Check if current Indian Standard Time has exceeded the lockout release window
            IF l_user.apex_locked_until IS NOT NULL 
               AND GET_IST_SYSTIMESTAMP >= l_user.apex_locked_until THEN
                
                -- TIME EXPIRED: Automatically restore full account access
                UPDATE apex_face_users
                   SET apex_is_locked     = 'N',
                       apex_failed_count  = 0,
                       apex_locked_until  = NULL
                 WHERE apex_user_id = l_user.apex_user_id;
            ELSE
                -- TIME ACTIVE: Format unlock time and reject authentication attempt
                l_unlock_time := TO_CHAR(l_user.apex_locked_until, 'HH:MI:SS AM');
                
                apex_error.add_error(
                    p_message          => 'Account is locked due to multiple failed attempts. It will auto-unlock at ' 
                                          || NVL(l_unlock_time, TO_CHAR(gc_lockout_duration_minutes) || ' minutes') || '.',
                    p_display_location => apex_error.c_inline_in_notification
                );
                RETURN FALSE;
            END IF;
        END IF;

        -- --------------------------------------------------------------------
        -- CASE A: Face Biometric Single-Use Token Verification
        -- --------------------------------------------------------------------
        IF SUBSTR(TRIM(p_password), 1, 9) = 'APEX_BIO_' THEN
            -- Validate that the token matches and has not passed its expiration timestamp
            IF l_user.apex_auth_token = TRIM(p_password) 
               AND GET_IST_SYSTIMESTAMP <= l_user.apex_token_expiry THEN
                
                -- Immediately wipe token from database to prevent replay attacks
                UPDATE apex_face_users
                   SET apex_auth_token    = NULL,
                       apex_token_expiry  = NULL,
                       apex_failed_count  = 0,
                       apex_is_locked     = 'N',
                       apex_locked_until  = NULL,
                       apex_last_login    = GET_IST_SYSTIMESTAMP
                 WHERE apex_user_id = l_user.apex_user_id;
                 
                RETURN TRUE;
            ELSE
                RETURN FALSE;
            END IF;
        END IF;

        -- --------------------------------------------------------------------
        -- CASE B: Standard Deterministic Password Verification
        -- --------------------------------------------------------------------
        IF l_user.apex_pwd_hash IS NOT NULL THEN
            -- Re-compute hash from plaintext password entered by the user
            l_computed_hash := apex_hash_pwd(l_clean_uname, TRIM(p_password));

            IF l_user.apex_pwd_hash = l_computed_hash THEN
                -- Successful login: Reset failed counters, clear lock flags, update audit date
                UPDATE apex_face_users
                   SET apex_failed_count  = 0,
                       apex_is_locked     = 'N',
                       apex_locked_until  = NULL,
                       apex_last_login    = GET_IST_SYSTIMESTAMP
                 WHERE apex_user_id = l_user.apex_user_id;
                 
                RETURN TRUE;
            ELSE
                -- Failed login: Increment attempts counter
                -- When threshold (gc_max_failed_attempts) is reached, lock account for gc_lockout_duration_minutes
                UPDATE apex_face_users
                   SET apex_failed_count = NVL(apex_failed_count, 0) + 1,
                       apex_is_locked    = CASE 
                                             WHEN NVL(apex_failed_count, 0) + 1 >= gc_max_failed_attempts THEN 'Y' 
                                             ELSE 'N' 
                                           END,
                       apex_locked_until = CASE 
                                             WHEN NVL(apex_failed_count, 0) + 1 >= gc_max_failed_attempts 
                                             THEN GET_IST_SYSTIMESTAMP + (gc_lockout_duration_minutes / 1440) 
                                             ELSE NULL 
                                           END
                 WHERE apex_user_id = l_user.apex_user_id;
                 
                RETURN FALSE;
            END IF;
        END IF;

        RETURN FALSE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- User record does not exist
            RETURN FALSE;
    END apex_authenticate_user;

END apex_pkg_face_security;
/