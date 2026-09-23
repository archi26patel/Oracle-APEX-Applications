create or replace PACKAGE XXPI_STRIPE_PAYMENT AS 
 
   PROCEDURE create_checkout_session_and_create_order( 
      p_amount      IN VARCHAR2, 
      p_user_name   IN VARCHAR2 
   ); 
 
    PROCEDURE update_payment_status_and_order_table( 
        p_amount OUT NUMBER, 
        p_order_id  OUT VARCHAR2 
    ); 
 
END XXPI_STRIPE_PAYMENT;
/