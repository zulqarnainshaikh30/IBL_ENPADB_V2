SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*
-Created By    :- Dara Singh
-Creation Date :- 19/06/2013
-Description   :- This Function Returns a Flag as "Y" or "N" which indicates 
                  User is authenticated or not.     
*/

CREATE FUNCTION [dbo].[AuthenticationFlag]
()
RETURNS VARCHAR(5)
AS
BEGIN
	RETURN 'Y' 
END



GO