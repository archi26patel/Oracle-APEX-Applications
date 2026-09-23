create or replace PACKAGE XXPI_PAYMENT_RESPONSE AS 
 
    -- Insert Razorpay Response 
    PROCEDURE RP_INSERT_RAZORPAY_RESPONSE( 
        p_amount_pay IN NUMBER, 
        p_user_name   IN VARCHAR2,  
        p_order_id OUT VARCHAR2  
    ); 
 
      -- RAzorpay AJAX Callback Procedure 
    PROCEDURE RP_SAVE_RAZORPAY_SUCCESS( 
        p_payment_id IN VARCHAR2, 
        p_order_id   IN VARCHAR2, 
        p_signature  IN VARCHAR2 
    ); 
     
 
    -- Update Razorpay Success Response 
    PROCEDURE RP_UPDATE_RAZORPAY_SUCCESS_RESPONSE_AND_CREATE_ORDER( 
        p_amount_paid  OUT NUMBER,  
        p_o_order_id OUT NUMBER  
    ); 
     
 
    -- Update Razorpay Failed Response 
    PROCEDURE RP_UPDATE_RAZORPAY_FAIL_RESPONSE( 
        p_order_id IN VARCHAR2, 
        p_amount_paid  OUT NUMBER,  
        p_o_order_id OUT VARCHAR2  
    ); 
 
    -- Create Or Insert Stripe Session 
    PROCEDURE SP_STRIPE_CHECKOUT_SESSION( 
      p_amount      IN VARCHAR2, 
      p_user_name   IN VARCHAR2 
   ); 
 
 
     -- Update Stripe Response 
    PROCEDURE SP_UPDATE_STRIPE_RESPONSE_AND_ORDER( 
        p_amount OUT NUMBER, 
        p_order_id  OUT VARCHAR2 
    ); 
END XXPI_PAYMENT_RESPONSE;
/