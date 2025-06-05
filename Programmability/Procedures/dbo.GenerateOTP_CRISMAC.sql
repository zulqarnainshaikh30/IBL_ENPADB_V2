SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[GenerateOTP_CRISMAC]

--Declare 

@UserId       VARCHAR(20) = 'lvl2admin', 
@OTP          VARCHAR(25)         = null
AS
     SET DATEFORMAT DMY;
     SET NOCOUNT ON;
     DECLARE @TimeKey int;

     SELECT @TimeKey = TimeKey
     FROM SysDayMatrix
     WHERE CONVERT(VARCHAR(10), Date, 103) = CONVERT(VARCHAR(10), GETDATE(), 103);
    BEGIN TRY
        BEGIN
            

            BEGIN TRANSACTION;
            
			Update OTP_CRISMAC set EffectiveToTimeKey=@TimeKey-1 where USERId = @UserId
			and EffectiveToTimeKey >= @TimeKey

            INSERT INTO [OTP_CRISMAC]
            (USERId, 
			MobileNo,
			[EmailId],
             OTP, 
             StartTime, 
             EndTime, 
             EffectiveFromTimeKey, 
             EffectiveToTimeKey, 
             CreatedBy, 
             DateCreated
            )
			Select UserLoginID, 
			MobileNo,
			Email_ID,
             @OTP, 
             GETDATE(), 
            (
                SELECT DATEADD(MINUTE, CAST(
                (
                    SELECT ParameterValue
                    FROM SysSolutionParameter
                    WHERE ParameterName = 'OTP_ExpiredMin'
                ) AS INT), GETDATE())
            ), 
             @TimeKey, 
             49999, 
             'D2k', 
             GETDATE()
            from DimUserInfo
                WHERE UserLoginId = @UserId
                AND EffectiveFromTimeKey <= @TimeKey
                AND EffectiveToTimeKey >= @TimeKey
				;
        END;
        COMMIT TRANSACTION;
        BEGIN
		    SELECT UserName,Email_ID,u.MobileNo,o.StartTime,o.EndTime, (Select Count(*) from [OTP_CRISMAC] Where USERId=u.UserLoginID
					And StartTime>=DATEADD(MINUTE, - 15, o.StartTime) and StartTime<=o.StartTime and EffectiveFromTimeKey = @TimeKey) as OtpCount
                FROM DimUserInfo u
				inner join [OTP_CRISMAC] o on o.USERId=u.UserLoginID and o.EffectiveToTimeKey >= @TimeKey
                WHERE UserLoginId = @UserId
                AND u.EffectiveFromTimeKey <= @TimeKey
                AND u.EffectiveToTimeKey >= @TimeKey
			

            RETURN
        END;
		SELECT UserName,Email_ID,u.MobileNo,o.StartTime,o.EndTime
                FROM DimUserInfo u
				inner join [OTP_CRISMAC] o on o.USERId=u.UserLoginID and o.EffectiveToTimeKey >= @TimeKey
                WHERE UserLoginId = @UserId
                AND u.EffectiveFromTimeKey <= @TimeKey
                AND u.EffectiveToTimeKey >= @TimeKey
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT ERROR_MESSAGE() ERRORDESC;
        RETURN
    END CATCH;
GO