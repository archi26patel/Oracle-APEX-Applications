create or replace PACKAGE BODY XXPI_RAZORPAY_PAYMENT AS 
 
    PROCEDURE INSERT_RAZORPAY_RESPONSE_AND_ORDER_DETAILS( 
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
        p_username    => 'rzp_test_RD6JUoeu30e1cx',     
        p_password    => 'xRcr3AbA4ZPPnPgATTJHqIcY',      
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
 
END INSERT_RAZORPAY_RESPONSE_AND_ORDER_DETAILS; 
 
 
PROCEDURE SAVE_RAZORPAY_SUCCESS( 
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
 END SAVE_RAZORPAY_SUCCESS; 
 
 
 
PROCEDURE UPDATE_RAZORPAY_SUCCESS_RESPONSE_AND_ORDER_DETAILS( 
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
        p_username    => 'rzp_test_RD6JUoeu30e1cx',     
        p_password    => 'xRcr3AbA4ZPPnPgATTJHqIcY' 
    ); 
 
  
    apex_json.parse(l_resp_clob); 
 
   
    v_amount      := apex_json.get_number(p_path => 'amount') / 100;  
    v_amount_paid := apex_json.get_number(p_path => 'amount_paid') / 100; 
    v_amount_due  := apex_json.get_number(p_path => 'amount_due') / 100; 
    v_order_status      := apex_json.get_varchar2(p_path => 'status'); 
 
 
    l_payment_resp_clob := apex_web_service.make_rest_request( 
        p_url         => 'https://api.razorpay.com/v1/orders/' || v_order_id || '/payments',   
        p_http_method => 'GET',                                    
        p_username    => 'rzp_test_RD6JUoeu30e1cx',     
        p_password    => 'xRcr3AbA4ZPPnPgATTJHqIcY' 
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

            DELETE FROM XXPI_CART
            WHERE USER_ID = v('APP_USER_ID');

            APEX_UTIL.SET_SESSION_STATE('APP_USER_CART_COUNT','0');
 
         UPDATE XXPI_PAYMENT_RESPONSE_HIST 
         SET ORDER_ID = l_order_id 
         WHERE R_ORDER_ID = v_order_id; 
 
    SELECT TOTAL_AMOUNT,ORDER_ID INTO p_amount_paid, p_o_order_id 
    FROM XXPI_ORDERS 
    WHERE RAZORPAY_ORDER_ID = v_order_id; 
 
    -- Optional: clear collection after use 
    apex_collection.delete_collection('RAZORPAY_SUCCESS'); 
 
  END IF; 
END UPDATE_RAZORPAY_SUCCESS_RESPONSE_AND_ORDER_DETAILS; 
 
 
 
PROCEDURE UPDATE_RAZORPAY_FAIL_RESPONSE_AND_ORDER_DETAILS( 
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
        p_username    => 'rzp_test_RD6JUoeu30e1cx',     
        p_password    => 'xRcr3AbA4ZPPnPgATTJHqIcY' 
    ); 
 
  
    apex_json.parse(l_resp_clob); 
 
   
    v_amount      := apex_json.get_number(p_path => 'amount') / 100;  
    v_amount_paid := apex_json.get_number(p_path => 'amount_paid') / 100; 
    v_amount_due  := apex_json.get_number(p_path => 'amount_due') / 100; 
    v_order_status      := apex_json.get_varchar2(p_path => 'status'); 
 
 
    l_payment_resp_clob := apex_web_service.make_rest_request( 
        p_url         => 'https://api.razorpay.com/v1/orders/' || v_order_id || '/payments',   
        p_http_method => 'GET',                                    
        p_username    => 'rzp_test_RD6JUoeu30e1cx',     
        p_password    => 'xRcr3AbA4ZPPnPgATTJHqIcY' 
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
END UPDATE_RAZORPAY_FAIL_RESPONSE_AND_ORDER_DETAILS; 
 
 
END XXPI_RAZORPAY_PAYMENT;
/