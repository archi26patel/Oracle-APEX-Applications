create or replace PACKAGE XXPI_RAZORPAY_PAYMENT AS 
 
    PROCEDURE INSERT_RAZORPAY_RESPONSE_AND_ORDER_DETAILS( 
        p_amount_pay IN NUMBER, 
        p_user_name   IN VARCHAR2,  
        p_order_id OUT VARCHAR2  
    ); 
 
    PROCEDURE SAVE_RAZORPAY_SUCCESS( 
        p_payment_id IN VARCHAR2, 
        p_order_id   IN VARCHAR2, 
        p_signature  IN VARCHAR2 
    ); 
     
    PROCEDURE UPDATE_RAZORPAY_SUCCESS_RESPONSE_AND_ORDER_DETAILS( 
        p_amount_paid  OUT NUMBER,  
        p_o_order_id OUT NUMBER  
    ); 
     
    PROCEDURE UPDATE_RAZORPAY_FAIL_RESPONSE_AND_ORDER_DETAILS( 
        p_order_id IN VARCHAR2, 
        p_amount_paid  OUT NUMBER,  
        p_o_order_id OUT VARCHAR2  
    ); 
 
END XXPI_RAZORPAY_PAYMENT;
/