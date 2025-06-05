SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
 
-- =============================================
 
-- Author:        DEEPAK JANGRA
 
-- Create date: 20th FEB 2018
 
-- Description:    Function returns first day of month [date]
 
-- =============================================
 
CREATE FUNCTION [dbo].[BOMonth] ( @dateIN DATE )
 
RETURNS DATE
 
AS
 
BEGIN
 
DECLARE @Result DATE
 
SELECT @Result = DATEADD(dd, -DAY(@dateIN) + 1, @dateIN)
RETURN @Result
 
END
 

GO