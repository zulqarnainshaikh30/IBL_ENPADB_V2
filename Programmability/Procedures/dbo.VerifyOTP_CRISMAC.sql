SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[VerifyOTP_CRISMAC]

--Declare 

@UserId      VARCHAR(20) = 9158104807, 
@OTP          VARCHAR(25) = 9158104807, 
@Result       INT         = 0 OUTPUT
AS
     SET DATEFORMAT DMY;
     SET NOCOUNT ON;
     DECLARE @TimeKey int;
     SELECT @TimeKey = TimeKey
     FROM SysDayMatrix
     WHERE CONVERT(VARCHAR(10), Date, 103) = CONVERT(VARCHAR(10), GETDATE(), 103);
	 print @TimeKey
     BEGIN TRANSACTION;
    BEGIN TRY
        BEGIN
		
            IF EXISTS
            (
                SELECT 1
                FROM OTP_CRISMAC
                WHERE(EffectiveFromTimeKey <= @TimeKey
                      AND EffectiveToTimeKey >= @TimeKey)
                     AND UserId = @UserId
					 anD EffectiveFromTimeKey = @TimeKey
                     AND OTP = @OTP
                     --AND EndTime >= FORMAT(GETDATE(), 'HH:mm:ss tt')
					 and CAST(isnull(StartTime,'00:00:00') As Time) <= CAST(getdate() As Time)
            )
                BEGIN
                    SET @Result = 1;
                    PRINT @Result;
                END;
                ELSE
                BEGIN
                    SET @Result = 0;
                    PRINT @Result;
                   
                END;

                    --END

        END;
        COMMIT TRANSACTION;
        BEGIN
            RETURN @Result;
        END;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT ERROR_MESSAGE() ERRORDESC;
        SET @RESULT = -1;
        RETURN @Result;
    END CATCH;
GO