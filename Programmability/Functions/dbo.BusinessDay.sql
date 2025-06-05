SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
 
 --DROP FUNCTION BusinessDay
CREATE FUNCTION [dbo].[BusinessDay](@date date)
RETURNS date
AS
BEGIN
while (SELECT DATENAME(WEEKDAY,@date))='Sunday'
begin
Select @date=(DATEADD(DD,-1,@date))
end
Return @date
END 
--GO 
--SELECT BusinessDay('2018-06-17')
GO