create or replace PACKAGE apex_pkg_face_security AS


/**
 * ============================================================================
 * PACKAGE SPECIFICATION : APEX_PKG_FACE_SECURITY
 * PURPOSE               : Core security layer for Biometric Face & Password 
 *                         Hybrid Authentication in Oracle APEX.
 *
 * ARCHITECTURAL ROLES   :
 * 1. apex_set_user_password : Generates and stores a session-independent,
 *                             deterministic SHA-256 salted hash for credentials.
 * 2. apex_gen_face_token    : Issues a high-entropy, short-lived single-use nonce
 *                             token (`APEX_BIO_...`) when a face is positively matched.
 * 3. apex_authenticate_user : APEX Custom Authentication Scheme core function that
 *                             verifies standard passwords or single-use biometric tokens
 *                             while managing account lockouts and attempt counters.
 * ============================================================================
 */

    /**
     * Hashes the plaintext password using deterministic SHA-256 and updates
     * the user's record in APEX_FACE_USERS while resetting failed attempt counts.
     *
     * @param p_username  The target username (case-insensitive)
     * @param p_password  The plaintext password to be hashed and stored
     */
    PROCEDURE apex_set_user_password(
        p_username IN VARCHAR2,
        p_password IN VARCHAR2
    );

    /**
     * Generates a single-use biometric nonce token valid for 3 minutes upon 
     * successful facial verification and assigns it to the target account.
     *
     * @param p_username  The verified account username
     * @return            Generated secure token string prefixed with 'APEX_BIO_'
     */
    FUNCTION apex_gen_face_token(
        p_username IN VARCHAR2
    ) RETURN VARCHAR2;

    /**
     * Main APEX authentication entrypoint. Evaluates credentials against either:
     * - Case A: Temporary single-use biometric token (and immediately revokes it)
     * - Case B: Deterministic salted SHA-256 password hash
     *
     * @param p_username  The authenticating username
     * @param p_password  The submitted credential (password or biometric token)
     * @return            TRUE if authentication succeeds; FALSE otherwise
     */
    FUNCTION apex_authenticate_user(
        p_username IN VARCHAR2,
        p_password IN VARCHAR2
    ) RETURN BOOLEAN;

END apex_pkg_face_security;
/