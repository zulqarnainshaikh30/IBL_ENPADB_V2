SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
create PROCEDURE [dbo].[UserIDInfowithEmail] 
	
	@UserEmail varchar(50)

AS 


BEGIN
Declare @TimeKey INT
 SET @TimeKey=(SELECT TimeKey FROM SysDayMatrix WHERE CAST(Date AS DATE)=CAST(GETDATE() AS DATE))
	Select * from DimUserInfo where (EffectiveFromTimeKey < = @TimeKey AND EffectiveToTimeKey  > = @TimeKey)
							   AND Email_ID=@UserEmail 
END






GO