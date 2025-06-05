SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[UserDetailInformation]
--Declare
 @UserID Varchar(50) 
AS

	BEGIN 

	SET NOCOUNT ON; 

		Select 
		UserLoginID,
		LoginPassword,
		SailPoint 
		from  DimUserInfo  where UserLoginID=@UserID
		-- and EffectiveToTimeKey=49999;	

    END;


GO