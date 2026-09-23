create or replace PACKAGE BODY XXPI_PAYMENT_RESPONSE AS 
 
    /****************   Insert Razorpay Response ******************/ 
    PROCEDURE RP_INSERT_RAZORPAY_RESPONSE( 
        p_amount_pay IN NUMBER, 
        p_user_name   IN VARCHAR2,  
        p_order_id OUT VARCHAR2   
    ) AS 
        l_resp_clob        clob; 
        l_body_clob        clob; 
        order_SEQ          NUMBER; 
 
        v_order_id            VARCHAR2(400); 
        v_entity        VARCHAR2(400); 
        v_amount        NUMBER; 
        v_amount_paid   NUMBER; 
        v_amount_due    NUMBER; 
        v_currency      VARCHAR2(400); 
        v_receipt       VARCHAR2(400); 
        v_offer_id      VARCHAR2(400); 
        v_status        VARCHAR2(400); 
        v_attempts      VARCHAR2(400); 
        v_created_at    date; 
 
        l_order_id number; 
    BEGIN 
  
        IF p_amount_pay <= 0 THEN 
            RAISE_APPLICATION_ERROR(-20001, 'Invalid p_amount_pay. The value must be greater than zero.'); 
        END IF; 
  
    l_body_clob := '{"amount": ' || p_amount_pay * 100 || ',"currency": "INR","receipt": "' || XXPI_RAZORPAY_ORDER_SEQ.NEXTVAL || '"}';     
 
  
    apex_web_service.g_request_headers(1).name := 'Content-Type';   
    apex_web_service.g_request_headers(1).value := 'application/json'; 
 
    l_resp_clob := apex_web_service.make_rest_request( 
        p_url         => 'https://api.razorpay.com/v1/orders',   
        p_http_method => 'POST',                                    
        p_username    => 'test_username',
        p_password    => 'test_password',
        p_body        => l_body_clob 
    ); 
 
  
    apex_json.parse(l_resp_clob); 
 
    v_order_id          := apex_json.get_varchar2(p_path => 'id'); 
    v_entity      := apex_json.get_varchar2(p_path => 'entity'); 
    v_amount      := apex_json.get_number(p_path => 'amount') / 100;  
    v_amount_paid := apex_json.get_number(p_path => 'amount_paid') / 100; 
    v_amount_due  := apex_json.get_number(p_path => 'amount_due') / 100; 
    v_currency    := apex_json.get_varchar2(p_path => 'currency'); 
    v_receipt     := apex_json.get_varchar2(p_path => 'receipt'); 
    v_offer_id    := apex_json.get_varchar2(p_path => 'offer_id'); 
    v_status      := apex_json.get_varchar2(p_path => 'status'); 
    v_attempts    := apex_json.get_varchar2(p_path => 'attempts'); 
    v_created_at  := TO_DATE('01-JAN-1970', 'DD-MON-YYYY') + (apex_json.get_number(p_path => 'created_at') / 60 / 60 / 24); 
 
 
    INSERT INTO XXPI_PAYMENT_RESPONSE_HIST ( 
      R_ORDER_ID, 
      PAYMENT_TYPE_ID,  
      R_ENTITY, 
      AMOUNT, 
      R_AMOUNT_PAID, 
      R_AMOUNT_DUE, 
      CURRENCY, 
      R_ORDER_STATUS, 
      OS_CREATED_AT, 
      USER_ID, 
      USER_NAME 
    ) VALUES ( 
      v_order_id, 
       1, 
      v_entity, 
      v_amount, 
      v_amount_paid, 
      v_amount_due, 
      v_currency, 
      v_status, 
      v_created_at, 
      v('APP_USER_ID'), 
      p_user_name 
    ); 
 
    p_order_id := v_order_id; 
 
END RP_INSERT_RAZORPAY_RESPONSE; 
 
 
/****************   Razorpay AJAX Callback Proceduree ******************/ 
 
PROCEDURE RP_SAVE_RAZORPAY_SUCCESS( 
    p_payment_id IN VARCHAR2, 
    p_order_id   IN VARCHAR2, 
    p_signature  IN VARCHAR2 
) IS 
  BEGIN 
    -- if collection exist then delete 
    IF apex_collection.collection_exists('RAZORPAY_SUCCESS') THEN 
      apex_collection.delete_collection('RAZORPAY_SUCCESS'); 
    END IF; 
 
    -- create collection  
    apex_collection.create_collection('RAZORPAY_SUCCESS'); 
 
    -- insert data into collection 
    apex_collection.add_member( 
      p_collection_name => 'RAZORPAY_SUCCESS', 
      p_c001 => p_payment_id, -- PAYMENT_ID 
      p_c002 => p_order_id,   -- ORDER_ID 
      p_c003 => p_signature   -- SIGNATURE 
    ); 
 END RP_SAVE_RAZORPAY_SUCCESS; 
 
 
/****************  Update Razorpay Success Response ******************/ 
 
PROCEDURE RP_UPDATE_RAZORPAY_SUCCESS_RESPONSE_AND_CREATE_ORDER( 
    p_amount_paid  OUT NUMBER,  
    p_o_order_id OUT NUMBER  
)IS 
    v_payment_id  VARCHAR2(400); 
    v_order_id    VARCHAR2(400); 
    v_signature   VARCHAR2(400); 
    l_order_id   NUMBER; 
 
    l_resp_clob        clob; 
    l_payment_resp_clob clob; 
    v_amount        NUMBER; 
    v_amount_paid   NUMBER; 
    v_amount_due    NUMBER; 
    v_order_status  VARCHAR2(400); 
     
    v_payment_status  VARCHAR2(400); 
    v_payment_created_at    date; 
BEGIN 
  -- Check if collection exists 
  IF apex_collection.collection_exists('RAZORPAY_SUCCESS') THEN 
 
    -- Read data from collection (latest row) 
    SELECT 
      c001,  -- PAYMENT_ID 
      c002,  -- ORDER_ID 
      c003   -- SIGNATURE 
    INTO 
      v_payment_id, 
      v_order_id, 
      v_signature 
    FROM apex_collections 
    WHERE collection_name = 'RAZORPAY_SUCCESS' 
      AND seq_id = ( 
        SELECT MAX(seq_id) 
        FROM apex_collections 
        WHERE collection_name = 'RAZORPAY_SUCCESS' 
      ); 
 
 
    l_resp_clob := apex_web_service.make_rest_request( 
        p_url         => 'https://api.razorpay.com/v1/orders/' || v_order_id,   
        p_http_method => 'GET',                                    
        p_username    => 'test_username',
        p_password    => 'test_password' 
    ); 
 
  
    apex_json.parse(l_resp_clob); 
 
   
    v_amount      := apex_json.get_number(p_path => 'amount') / 100;  
    v_amount_paid := apex_json.get_number(p_path => 'amount_paid') / 100; 
    v_amount_due  := apex_json.get_number(p_path => 'amount_due') / 100; 
    v_order_status      := apex_json.get_varchar2(p_path => 'status'); 
 
 
    l_payment_resp_clob := apex_web_service.make_rest_request( 
        p_url         => 'https://api.razorpay.com/v1/orders/' || v_order_id || '/payments',   
        p_http_method => 'GET',                                    
        p_username    => 'test_username',
        p_password    => 'test_password' 
    ); 
 
    apex_json.parse(l_payment_resp_clob); 
 
    v_payment_status := apex_json.get_varchar2('items[1].status'); 
    v_payment_created_at  := TO_DATE('01-JAN-1970', 'DD-MON-YYYY') + (apex_json.get_number(p_path => 'items[1].created_at') / 60 / 60 / 24); 
 
    UPDATE XXPI_PAYMENT_RESPONSE_HIST 
    SET 
      PAYMENT_ID   = v_payment_id, 
      R_P_ORDER_ID   = v_order_id, 
      R_SIGNATURE    = v_signature, 
      AMOUNT       = v_amount, 
      R_AMOUNT_PAID  = v_amount_paid, 
      R_AMOUNT_DUE   = v_amount_due, 
      R_ORDER_STATUS = v_order_status, 
      PAYMENT_STATUS = v_payment_status, 
      R_ORDER_RESPONSE_JSON   = l_resp_clob, 
      PAYMENT_RESPONSE_JSON = l_payment_resp_clob, 
      PAYMENT_CREATED_AT= v_payment_created_at 
    WHERE R_ORDER_ID = v_order_id; 
 
 
     -- Insert Into Order Table 
 
        INSERT INTO XXPI_ORDERS( 
            USER_ID, 
            TOTAL_AMOUNT, 
            PAYMENT_STATUS, 
            RAZORPAY_ORDER_ID 
        ) VALUES ( 
            v('APP_USER_ID'), 
            v_amount, 
            v_payment_status, 
            v_order_id 
        ) 
 
        RETURNING ORDER_ID INTO l_order_id; 
 
        INSERT INTO XXPI_ORDER_ITEMS( 
            ORDER_ID, 
            PRODUCT_ID, 
            QTY, 
            PRICE 
        ) 
            SELECT  
                l_order_id, 
                C.PRODUCT_ID, 
                C.QTY, 
                (P.PRICE * C.QTY) 
            FROM XXPI_CART C 
            INNER JOIN XXPI_PRODUCTS P 
            ON C.PRODUCT_ID  = P.PRODUCT_ID  
            WHERE C.USER_ID = v('APP_USER_ID'); 
 
         UPDATE XXPI_PAYMENT_RESPONSE_HIST 
         SET ORDER_ID = l_order_id 
         WHERE R_ORDER_ID = v_order_id; 

         DELETE FROM XXPI_CART
         WHERE USER_ID = v('APP_USER_ID');

         APEX_UTIL.SET_SESSION_STATE('APP_USER_CART_COUNT','0');
 
    SELECT TOTAL_AMOUNT,ORDER_ID INTO p_amount_paid, p_o_order_id 
    FROM XXPI_ORDERS 
    WHERE RAZORPAY_ORDER_ID = v_order_id; 
 
    -- Optional: clear collection after use 
    apex_collection.delete_collection('RAZORPAY_SUCCESS'); 
 
  END IF; 
END RP_UPDATE_RAZORPAY_SUCCESS_RESPONSE_AND_CREATE_ORDER; 
 
 
/**************** Update Razorpay Failed Response ******************/ 
 
PROCEDURE RP_UPDATE_RAZORPAY_FAIL_RESPONSE( 
        p_order_id IN VARCHAR2, 
        p_amount_paid  OUT NUMBER,  
        p_o_order_id OUT VARCHAR2  
)IS 
    v_payment_id  VARCHAR2(400); 
    v_order_id    VARCHAR2(400); 
 
    l_resp_clob        clob; 
    l_payment_resp_clob clob; 
    v_amount        NUMBER; 
    v_amount_paid   NUMBER; 
    v_amount_due    NUMBER; 
    v_order_status  VARCHAR2(400); 
     
    v_payment_status  VARCHAR2(400); 
    v_payment_created_at    date; 
BEGIN 
  -- Check if collection exists 
  IF p_order_id IS NOT NULL THEN 
 
  v_order_id := p_order_id; 
 
    l_resp_clob := apex_web_service.make_rest_request( 
        p_url         => 'https://api.razorpay.com/v1/orders/' || v_order_id,   
        p_http_method => 'GET',                                    
        p_username    => 'test_username',    
        p_password    => 'test_password' 
    ); 
 
  
    apex_json.parse(l_resp_clob); 
 
   
    v_amount      := apex_json.get_number(p_path => 'amount') / 100;  
    v_amount_paid := apex_json.get_number(p_path => 'amount_paid') / 100; 
    v_amount_due  := apex_json.get_number(p_path => 'amount_due') / 100; 
    v_order_status      := apex_json.get_varchar2(p_path => 'status'); 
 
 
    l_payment_resp_clob := apex_web_service.make_rest_request( 
        p_url         => 'https://api.razorpay.com/v1/orders/' || v_order_id || '/payments',   
        p_http_method => 'GET',                                    
        p_username    => 'test_username',     
        p_password    => 'test_password' 
    ); 
 
    apex_json.parse(l_payment_resp_clob); 
 
    v_payment_id   := apex_json.get_varchar2('items[1].id'); 
    v_payment_status := apex_json.get_varchar2('items[1].status'); 
     
    v_payment_created_at  := TO_DATE('01-JAN-1970', 'DD-MON-YYYY') + (apex_json.get_number(p_path => 'items[1].created_at') / 60 / 60 / 24); 
 
    UPDATE XXPI_PAYMENT_RESPONSE_HIST 
    SET 
      PAYMENT_ID   = v_payment_id, 
      R_P_ORDER_ID   = v_order_id, 
      AMOUNT       = v_amount, 
      R_AMOUNT_PAID  = v_amount_paid, 
      R_AMOUNT_DUE   = v_amount_due, 
      R_ORDER_STATUS = v_order_status, 
      PAYMENT_STATUS = v_payment_status, 
      R_ORDER_RESPONSE_JSON   = l_resp_clob, 
      PAYMENT_RESPONSE_JSON = l_payment_resp_clob, 
      PAYMENT_CREATED_AT= v_payment_created_at 
    WHERE R_ORDER_ID = v_order_id; 
 
    p_o_order_id := v_order_id; 
    p_amount_paid := v_amount; 
     
  END IF; 
END RP_UPDATE_RAZORPAY_FAIL_RESPONSE; 
 
 
 
/**************** Create Or Insert Stripe Session ******************/ 
 
 
PROCEDURE SP_STRIPE_CHECKOUT_SESSION( 
      p_amount      IN VARCHAR2, 
      p_user_name   IN VARCHAR2 
   ) IS 
      l_resp              CLOB; 
      l_body              VARCHAR2(32767); 
      l_amount            VARCHAR2(100) := TO_CHAR(TRUNC(TO_NUMBER(p_amount) * 100)); 
      l_url_s               VARCHAR2(2000); 
      l_url_f               VARCHAR2(2000); 
 
      -- Session JSON fields 
      l_session_id        VARCHAR2(1000); 
      l_payment_id        VARCHAR2(1000); 
      l_session_status    VARCHAR2(255); 
      l_session_paystatus VARCHAR2(255); 
      l_amount_res        NUMBER; 
      l_currency          VARCHAR2(255); 
      l_created_at    date; 
 
      l_order_id number; 
 
   BEGIN 
      -- Build URL with checksum 
      l_url_s := APEX_UTIL.PREPARE_URL( 
                  p_url => 'f?p=' || V('APP_ID') || ':5:' || V('APP_SESSION') || '::NO::', 
                  p_checksum_type => 'SESSION' 
               ); 
       
      l_url_f := APEX_UTIL.PREPARE_URL( 
                  p_url => 'f?p=' || V('APP_ID') || ':6:' || V('APP_SESSION') || '::NO::', 
                  p_checksum_type => 'SESSION' 
               ); 
 
      -- Build body for Stripe Checkout Session 
      l_body := 
            'success_url=' || utl_url.escape('https://oracleapex.com' || l_url_s) || 
         '&cancel_url='  || utl_url.escape('https://oracleapex.com' || l_url_f) || 
         '&mode=payment' || 
         '&line_items[0][price_data][currency]=inr' || 
         '&line_items[0][price_data][unit_amount]=' || l_amount || 
         '&line_items[0][price_data][product_data][name]=' || utl_url.escape(p_user_name) || 
         '&line_items[0][quantity]=1'; 
 
      -- Call Stripe Create Checkout Session API 
      l_resp := apex_web_service.make_rest_request( 
                   p_url         => 'https://api.stripe.com/v1/checkout/sessions', 
                   p_http_method => 'POST', 
                   p_username    => 'test_username',
                   p_password    => NULL, 
                   p_body        => l_body 
                ); 
 
      -- Parse JSON Response 
      APEX_JSON.parse(l_resp); 
 
      l_session_id        := APEX_JSON.get_varchar2('id'); 
      l_payment_id        := APEX_JSON.get_varchar2('payment_intent'); 
      l_session_status    := APEX_JSON.get_varchar2('status'); 
      l_session_paystatus := APEX_JSON.get_varchar2('payment_status'); 
      l_amount_res        := APEX_JSON.get_number('amount_total') / 100; 
      l_currency          := APEX_JSON.get_varchar2('currency'); 
      l_created_at  := TO_DATE('01-JAN-1970', 'DD-MON-YYYY') + (apex_json.get_number(p_path => 'created') / 60 / 60 / 24); 
 
      -- Insert into table 
      IF l_session_id IS NOT NULL THEN 
 
         INSERT INTO XXPI_PAYMENT_RESPONSE_HIST( 
            S_SESSION_ID, 
            PAYMENT_ID, 
            PAYMENT_TYPE_ID, 
            AMOUNT, 
            CURRENCY, 
            USER_ID, 
            USER_NAME, 
            OS_CREATED_AT 
         ) VALUES ( 
            l_session_id, 
            l_payment_id, 
            2, 
            l_amount_res, 
            UPPER(l_currency), 
            v('APP_USER_ID'), 
            p_user_name, 
            l_created_at 
         ); 
 
         -- Store in APEX Collection 
         IF NOT APEX_COLLECTION.COLLECTION_EXISTS('STORE_STRIPE_SESSION') THEN 
            APEX_COLLECTION.CREATE_COLLECTION('STORE_STRIPE_SESSION'); 
         END IF; 
 
         APEX_COLLECTION.ADD_MEMBER( 
            p_collection_name => 'STORE_STRIPE_SESSION', 
            p_c001            => l_session_id 
         ); 
      END IF; 
 
      -- Return JSON to AJAX 
      owa_util.mime_header('application/json', FALSE); 
      htp.init; 
      htp.p(l_resp); 
 
   EXCEPTION 
      WHEN OTHERS THEN 
         owa_util.mime_header('application/json', FALSE); 
         htp.init; 
         htp.p('{"error":"' || REPLACE(SQLERRM,'"','''') || '"}'); 
   END SP_STRIPE_CHECKOUT_SESSION; 
 
 
/**************** Update Stripe Response ******************/ 
 
PROCEDURE SP_UPDATE_STRIPE_RESPONSE_AND_ORDER( 
        p_amount OUT NUMBER, 
        p_order_id  OUT VARCHAR2 
    ) 
   IS 
    l_session_id       VARCHAR2(1000); 
    l_resp_session     CLOB; 
    l_resp_payment     CLOB; 
    l_tranc_balance     CLOB; 
 
    -- SESSION API VARIABLES 
    v_session_status          VARCHAR2(200); 
    v_session_payment_status  VARCHAR2(200); 
    v_amount_usd              NUMBER; 
    v_amount_inr              NUMBER; 
    v_session_created         DATE; 
 
    -- PAYMENT INTENT API VARIABLES 
    v_amount_received   NUMBER; 
    v_amount_captured   NUMBER; 
    v_payment_captured  VARCHAR2(20); 
    v_payment_status    VARCHAR2(50); 
    v_payment_balance_trans    VARCHAR2(100); 
    V_payment_created date; 
 
    v_payment_intent_id VARCHAR2(400); 
 
    l_order_id NUMBER; 
BEGIN 
   -- Get SESSION_ID from APEX collection 
   IF APEX_COLLECTION.COLLECTION_EXISTS('STORE_STRIPE_SESSION') THEN 
      SELECT c001  
        INTO l_session_id 
        FROM APEX_COLLECTIONS 
       WHERE COLLECTION_NAME = 'STORE_STRIPE_SESSION' 
       FETCH FIRST 1 ROWS ONLY; 
 
   -- 1) Checkout Session API (old) 
      l_resp_session := apex_web_service.make_rest_request( 
                 p_url         => 'https://api.stripe.com/v1/checkout/sessions/' || l_session_id, 
                 p_http_method => 'GET', 
                 p_username    => 'test_username', 
                 p_password    => NULL 
              ); 
 
      apex_json.parse(l_resp_session); 
 
      v_session_status         := apex_json.get_varchar2('status'); 
      v_session_payment_status := apex_json.get_varchar2('payment_status'); 
      v_amount_inr             := apex_json.get_number('amount_total') / 100; 
      v_session_created        := (DATE '1970-01-01' + apex_json.get_number('created')/86400); 
 
      v_payment_intent_id      := apex_json.get_varchar2('payment_intent'); 
 
 
   -- 2) Payment Intent API (new) 
      l_resp_payment := apex_web_service.make_rest_request( 
                 p_url         => 'https://api.stripe.com/v1/payment_intents/' || v_payment_intent_id, 
                 p_http_method => 'GET', 
                 p_username    => 'test_username', 
                 p_password    => NULL 
              ); 
 
      apex_json.parse(l_resp_payment); 
 
      v_amount_received  := apex_json.get_number('amount_received') / 100; 
      v_amount_captured  := NVL(apex_json.get_number('charges.data[1].amount_captured') / 100, 0); 
      v_payment_captured := NVL(apex_json.get_varchar2('charges.data[1].captured'), 'false'); 
      v_payment_status   := apex_json.get_varchar2('status'); 
      v_payment_balance_trans   := apex_json.get_varchar2('charges.data[1].balance_transaction'); 
      V_payment_created  := TO_DATE('01-JAN-1970', 'DD-MON-YYYY') + (apex_json.get_number(p_path => 'created') / 60 / 60 / 24); 
 
 
    -- 3) Payment Balance Transactions Json 
    IF v_payment_balance_trans IS NOT NULL THEN 
    l_tranc_balance := apex_web_service.make_rest_request( 
                 p_url         => 'https://api.stripe.com/v1/balance_transactions/' || v_payment_balance_trans, 
                 p_http_method => 'GET', 
                 p_username    => 'test_username', 
                 p_password    => NULL 
              ); 
    END IF; 
 
   -- Final Update into your DB 
      UPDATE XXPI_PAYMENT_RESPONSE_HIST 
         SET S_SESSION_STATUS          = v_session_status, 
             S_SESSION_PAYMENT_STATUS  = v_session_payment_status, 
             PAYMENT_CREATED_AT         = V_payment_created, 
             S_AMOUNT_RECEIVED     = v_amount_received, 
             S_AMOUNT_CAPTURED     = v_amount_captured, 
             S_PAYMENT_CAPTURED        = v_payment_captured, 
             PAYMENT_STATUS          = v_payment_status, 
             S_SESSION_RESPONSE_JSON   = l_resp_session, 
             S_BALANCE_TRANSACTION_JSON   = l_tranc_balance, 
             PAYMENT_RESPONSE_JSON   = l_resp_payment 
       WHERE S_SESSION_ID = l_session_id; 
 
       p_order_id := l_session_id; 
 
       IF v_payment_status = 'succeeded' THEN 
 
           --Insert Into Order Table 
 
        INSERT INTO XXPI_ORDERS( 
            USER_ID, 
            TOTAL_AMOUNT, 
            STRIPE_SESSION_ID, 
            PAYMENT_STATUS 
        ) VALUES ( 
            v('APP_USER_ID'), 
            v_amount_inr, 
            l_session_id, 
            v_payment_status 
        ) 
 
        RETURNING ORDER_ID INTO l_order_id; 
 
        INSERT INTO XXPI_ORDER_ITEMS( 
            ORDER_ID, 
            PRODUCT_ID, 
            QTY, 
            PRICE 
        ) 
            SELECT  
                l_order_id, 
                C.PRODUCT_ID, 
                C.QTY, 
                (P.PRICE * C.QTY) 
            FROM XXPI_CART C 
            INNER JOIN XXPI_PRODUCTS P 
            ON C.PRODUCT_ID  = P.PRODUCT_ID  
            WHERE C.USER_ID = v('APP_USER_ID'); 

            DELETE FROM XXPI_CART
            WHERE USER_ID = v('APP_USER_ID');

            APEX_UTIL.SET_SESSION_STATE('APP_USER_CART_COUNT','0');
 
        p_order_id := l_order_id; 
 
       END IF; 
 
       p_amount := v_amount_inr; 
 
        
        UPDATE XXPI_PAYMENT_RESPONSE_HIST 
        SET ORDER_ID = l_order_id 
        WHERE S_SESSION_ID = l_session_id; 
 
      -- Remove collection 
      APEX_COLLECTION.DELETE_COLLECTION('STORE_STRIPE_SESSION'); 

   END IF; 
END SP_UPDATE_STRIPE_RESPONSE_AND_ORDER; 
 
END XXPI_PAYMENT_RESPONSE;
/