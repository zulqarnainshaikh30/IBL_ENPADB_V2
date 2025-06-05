SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create Proc [dbo].[SetLoginCount] 
@OTP          VARCHAR(25) = 9158104807,
@Result       INT         = 0 OUTPUT
AS
BEGIN try
Update  OTP_CRISMAC set LoginCount = '1'  WHERE OTP = @OTP

						SET @Result=1
						RETURN @Result
					END try

					BEGIN CATCH
	SET @Result=0
	RETURN @Result

END CATCH
GO