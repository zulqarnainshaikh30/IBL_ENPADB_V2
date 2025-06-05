SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create PROC [dbo].[CollateralNameDropDown]

AS

BEGIN

Declare @Timekey Int
Set @Timekey=(Select TimeKey from SysDataMatrix where CurrentStatus='C')


		BEGIN
		
				select SecurityName
				,SecurityAlt_Key
				,'ColDescription' TableName
				from DIMSECURITY
				where EffectiveFromTimeKey<=@Timekey
				AND EffectiveToTimeKey>=@Timekey
		END

END

GO