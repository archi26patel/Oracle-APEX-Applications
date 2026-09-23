create or replace PACKAGE BODY XXPI_STRIPE_PAYMENT AS 
 
   PROCEDURE create_checkout_session_and_create_order( 
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
      ------------------------------------------------------------------- 
      -- Build URL with checksum 
      ------------------------------------------------------------------- 
      l_url_s := APEX_UTIL.PREPARE_URL( 
                  p_url => 'f?p=' || V('APP_ID') || ':5:' || V('APP_SESSION') || '::NO::', 
                  p_checksum_type => 'SESSION' 
               ); 
       
      l_url_f := APEX_UTIL.PREPARE_URL( 
                  p_url => 'f?p=' || V('APP_ID') || ':6:' || V('APP_SESSION') || '::NO::', 
                  p_checksum_type => 'SESSION' 
               ); 
 
      ------------------------------------------------------------------- 
      -- Build body for Stripe Checkout Session 
      ------------------------------------------------------------------- 
      l_body := 
            'success_url=' || utl_url.escape('https://oracleapex.com' || l_url_s) || 
         '&cancel_url='  || utl_url.escape('https://oracleapex.com' || l_url_f) || 
         '&mode=payment' || 
         '&line_items[0][price_data][currency]=inr' || 
         '&line_items[0][price_data][unit_amount]=' || l_amount || 
         '&line_items[0][price_data][product_data][name]=' || utl_url.escape(p_user_name) || 
         '&line_items[0][quantity]=1'; 
 
      ------------------------------------------------------------------- 
      -- Call Stripe Create Checkout Session API 
      ------------------------------------------------------------------- 
      l_resp := apex_web_service.make_rest_request( 
                   p_url         => 'https://api.stripe.com/v1/checkout/sessions', 
                   p_http_method => 'POST', 
                   p_username    => 'test_username', 
                   p_password    => NULL, 
                   p_body        => l_body 
                ); 
 
      ------------------------------------------------------------------- 
      -- Parse JSON Response 
      ------------------------------------------------------------------- 
      APEX_JSON.parse(l_resp); 
 
      l_session_id        := APEX_JSON.get_varchar2('id'); 
      l_payment_id        := APEX_JSON.get_varchar2('payment_intent'); 
      l_session_status    := APEX_JSON.get_varchar2('status'); 
      l_session_paystatus := APEX_JSON.get_varchar2('payment_status'); 
      l_amount_res        := APEX_JSON.get_number('amount_total') / 100; 
      l_currency          := APEX_JSON.get_varchar2('currency'); 
      l_created_at  := TO_DATE('01-JAN-1970', 'DD-MON-YYYY') + (apex_json.get_number(p_path => 'created') / 60 / 60 / 24); 
 
      ------------------------------------------------------------------- 
      -- Insert into table 
      ------------------------------------------------------------------- 
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
 
         ---------------------------------------------------------------- 
         -- Store in APEX Collection 
         ---------------------------------------------------------------- 
         IF NOT APEX_COLLECTION.COLLECTION_EXISTS('STORE_STRIPE_SESSION') THEN 
            APEX_COLLECTION.CREATE_COLLECTION('STORE_STRIPE_SESSION'); 
         END IF; 
 
         APEX_COLLECTION.ADD_MEMBER( 
            p_collection_name => 'STORE_STRIPE_SESSION', 
            p_c001            => l_session_id 
         ); 
      END IF; 
 
      ------------------------------------------------------------------- 
      -- Return JSON to AJAX 
      ------------------------------------------------------------------- 
      owa_util.mime_header('application/json', FALSE); 
      htp.init; 
      htp.p(l_resp); 
 
   EXCEPTION 
      WHEN OTHERS THEN 
         owa_util.mime_header('application/json', FALSE); 
         htp.init; 
         htp.p('{"error":"' || REPLACE(SQLERRM,'"','''') || '"}'); 
   END create_checkout_session_and_create_order; 
 
 
 
 
   PROCEDURE update_payment_status_and_order_table( 
        p_amount OUT NUMBER, 
        p_order_id  OUT VARCHAR2 
    ) 
   IS 
    l_session_id       VARCHAR2(1000); 
    l_resp_session     CLOB; 
    l_resp_payment     CLOB; 
 
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
    V_payment_created date; 
 
    v_payment_intent_id VARCHAR2(400); 
 
    l_order_id NUMBER; 
BEGIN 
   -------------------------------------------------------------------------- 
   -- Get SESSION_ID from APEX collection 
   -------------------------------------------------------------------------- 
   IF APEX_COLLECTION.COLLECTION_EXISTS('STORE_STRIPE_SESSION') THEN 
      SELECT c001  
        INTO l_session_id 
        FROM APEX_COLLECTIONS 
       WHERE COLLECTION_NAME = 'STORE_STRIPE_SESSION' 
       FETCH FIRST 1 ROWS ONLY; 
 
   -------------------------------------------------------------------------- 
   -- 1) Checkout Session API (old) 
   -------------------------------------------------------------------------- 
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
 
 
   -------------------------------------------------------------------------- 
   -- 2) Payment Intent API (new) 
   -------------------------------------------------------------------------- 
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
      V_payment_created  := TO_DATE('01-JAN-1970', 'DD-MON-YYYY') + (apex_json.get_number(p_path => 'created') / 60 / 60 / 24); 
 
 
   -------------------------------------------------------------------------- 
   -- Final Update into your DB 
   -------------------------------------------------------------------------- 
      UPDATE XXPI_PAYMENT_RESPONSE_HIST 
         SET S_SESSION_STATUS          = v_session_status, 
             S_SESSION_PAYMENT_STATUS  = v_session_payment_status, 
             PAYMENT_CREATED_AT         = V_payment_created, 
             S_AMOUNT_RECEIVED     = v_amount_received, 
             S_AMOUNT_CAPTURED     = v_amount_captured, 
             S_PAYMENT_CAPTURED        = v_payment_captured, 
             PAYMENT_STATUS          = v_payment_status, 
             S_SESSION_RESPONSE_JSON   = l_resp_session, 
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
 
      ---------------------------------------------------------------------- 
      -- Remove collection 
      ---------------------------------------------------------------------- 
      APEX_COLLECTION.DELETE_COLLECTION('STORE_STRIPE_SESSION'); 
   END IF; 
END update_payment_status_and_order_table; 
 
END XXPI_STRIPE_PAYMENT;
/