SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create Proc [dbo].[GetOTPHistory]
@OTP          VARCHAR(25) = 9158104807
AS

select *, 'GetOTPHistory' AS TableName 
                FROM OTP_CRISMAC
                WHERE OTP = @OTP
GO