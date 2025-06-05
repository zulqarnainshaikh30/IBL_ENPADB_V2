SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[CollateralCodeDropDown]

					@SecurityName VARCHAR(100)=''

AS

BEGIN

Declare @Timekey Int
Set @Timekey=(Select TimeKey from SysDataMatrix where CurrentStatus='C')


		BEGIN
		
				select SecurityAlt_Key
				,SecurityName
				from DIMSECURITY
				where SecurityName=@SecurityName
				AND EffectiveFromTimeKey<=@Timekey
				AND EffectiveToTimeKey>=@Timekey
		END

END
GO