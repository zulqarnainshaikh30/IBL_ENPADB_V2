SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[UserLoginInvokedUpdate]
	(
	 @UserLoginID varchar(20),
	 @LoginPassword varchar(50),
	 @TimeKey INT -- NITIN : 21 DEC 2010
	 ,@Result int =0 Output
	)
AS
  BEGIN
	

	IF (@UserLoginID = '' OR @LoginPassword = '')
			  BEGIN
			  PRINT 9
			  SET @Result=-10
			  ROLLBACK TRAN
					RETURN @Result -- Keeping Mandatory Columns blank while User Creation
				END

    IF NOT EXISTS(SELECT * from DimUserInfo where  (DimUserInfo.EffectiveFromTimeKey    < = @TimeKey   
	                 AND DimUserInfo.EffectiveToTimeKey  > = @TimeKey) AND UserLoginID =  @UserLoginID  AND UserLogged=1  )
			BEGIN
			BEGIN Tran
			ROLLBACK TRANSACTION
			set @Result = -1
			RETURN -1
	        END
      ELSE
		   BEGIN
		                UPDATE  DimUserInfo         
						SET
      					UserLogged=0
	 					WHERE UserLoginID=@UserLoginID AND
	 					(EffectiveFromTimeKey < = @TimeKey AND EffectiveToTimeKey  > = @TimeKey)
						
						DECLARE @LocationCode varchar(50)
                        DECLARE @Location varchar(10)
                        DECLARE @Count int
                        Select @LocationCode= UserLocationCode,@Location=UserLocation  From DimUserInfo WHERE UserLoginID=@UserLoginID AND
	 					(EffectiveFromTimeKey < = @TimeKey AND EffectiveToTimeKey  > = @TimeKey)
						print @Location
						if(@Location='HO')
		                BEGIN
		                  Select  @Count=UserLoginCount from DimMaxLoginAllow where UserLocation=@Location
		                END
		                if(@Location='RO')
		                BEGIN
		                   Select  @Count=UserLoginCount from DimMaxLoginAllow where UserLocation=@Location and UserLocationCode=@LocationCode 
		                END
		                if(@Location='BO')
		                BEGIN
		                Select  @Count=UserLoginCount from DimMaxLoginAllow where UserLocation=@Location and UserLocationCode=@LocationCode 
		                END
		                IF (@Count=0)
		                BEGIN
		                SET  @Count = @Count+1
		                END
		                ELSE
		                BEGIN
		                 SET  @Count = @Count-1
		                END
		                
		              --  EXEC sp_UpdateUserAccessCount @LocationCode,@Count,@Location
						set @Result = 1
	 					RETURN 1
			END
			
    END






GO