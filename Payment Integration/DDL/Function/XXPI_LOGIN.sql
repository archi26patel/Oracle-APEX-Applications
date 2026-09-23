create or replace FUNCTION XXPI_LOGIN ( 
      p_username  IN VARCHAR2, 
      p_password  IN VARCHAR2 
   ) RETURN BOOLEAN 
   AS 
      L_COUNT NUMBER; 
   BEGIN 
      SELECT COUNT(*) INTO L_COUNT  
      FROM  
         XXPI_USERS 
      WHERE  
         upper(EMAIL) = upper(p_username) 
         AND trim(PASSWORD) = trim(p_password); 
 
      RETURN L_COUNT > 0; 
END XXPI_LOGIN;
/