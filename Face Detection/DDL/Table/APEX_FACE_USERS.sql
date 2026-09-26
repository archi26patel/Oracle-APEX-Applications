  CREATE TABLE "APEX_FACE_USERS" 
   (	"APEX_USER_ID" NUMBER GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE, 
	"APEX_USERNAME" VARCHAR2(100) NOT NULL ENABLE, 
	"APEX_PWD_HASH" VARCHAR2(512), 
	"APEX_FACE_DESC" CLOB, 
	"APEX_AUTH_TOKEN" VARCHAR2(256), 
	"APEX_TOKEN_EXPIRY" TIMESTAMP (6), 
	"APEX_FAILED_COUNT" NUMBER DEFAULT 0, 
	"APEX_IS_LOCKED" VARCHAR2(1) DEFAULT 'N', 
	"APEX_CREATED_DATE" TIMESTAMP (6) DEFAULT SYSTIMESTAMP, 
	"APEX_LAST_LOGIN" TIMESTAMP (6), 
	"APEX_LOCKED_UNTIL" TIMESTAMP (6), 
	 PRIMARY KEY ("APEX_USER_ID")
  USING INDEX  ENABLE, 
	 UNIQUE ("APEX_USERNAME")
  USING INDEX  ENABLE
   ) ;


   COMMENT ON COLUMN "APEX_FACE_USERS"."APEX_USER_ID" IS 'Primary key auto-generated using identity sequence.';
   COMMENT ON COLUMN "APEX_FACE_USERS"."APEX_USERNAME" IS 'Unique case-insensitive username for login authentication.';
   COMMENT ON COLUMN "APEX_FACE_USERS"."APEX_PWD_HASH" IS 'Deterministic, session-independent SHA-256 salted hash of the user password.';
   COMMENT ON COLUMN "APEX_FACE_USERS"."APEX_FACE_DESC" IS 'Serialized JSON array holding 128 floating-point facial feature descriptors from face-api.js.';
   COMMENT ON COLUMN "APEX_FACE_USERS"."APEX_AUTH_TOKEN" IS 'Cryptographic, single-use nonce token (prefixed with APEX_BIO_) issued for biometric login.';
   COMMENT ON COLUMN "APEX_FACE_USERS"."APEX_TOKEN_EXPIRY" IS 'Expiration timestamp (3 minutes window) after which the biometric login token becomes invalid.';
   COMMENT ON COLUMN "APEX_FACE_USERS"."APEX_FAILED_COUNT" IS 'Counter tracking consecutive invalid login attempts for lockout threshold evaluation.';
   COMMENT ON COLUMN "APEX_FACE_USERS"."APEX_IS_LOCKED" IS 'Flag indicating whether the account is disabled due to exceeded failed attempts (Y = Locked, N = Unlocked).';
   COMMENT ON COLUMN "APEX_FACE_USERS"."APEX_CREATED_DATE" IS 'Audit timestamp indicating when the user profile and biometric template were enrolled.';
   COMMENT ON COLUMN "APEX_FACE_USERS"."APEX_LAST_LOGIN" IS 'Audit timestamp tracking the most recent successful login via password or face recognition.';
   COMMENT ON COLUMN "APEX_FACE_USERS"."APEX_LOCKED_UNTIL" IS 'Timestamp until which the account remains locked. Auto-unlocks after this time.';
   COMMENT ON TABLE "APEX_FACE_USERS"  IS 'Stores user identities, deterministic password hashes, face-api.js biometric templates, and single-use authentication tokens.';