﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*
-Created By    :- Dara Singh
-Creation Date :- 19/06/2013
-Description   :- This Function Returns a Flag as "Y" or "N" or "SQL" which indicates 
                  Active Directory Status is ON/OFF or retrieve data from UserManagement table respectively.        
*/

CREATE FUNCTION [dbo].[ADFlag]
()
RETURNS VARCHAR(5)
AS
BEGIN
	RETURN 'N' 
END
 



GO