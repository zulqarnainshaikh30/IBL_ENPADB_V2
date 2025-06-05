SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[SecurityChargeDropDown]

AS

BEGIN

Declare @Timekey Int
Set @Timekey=(Select TimeKey from SysDataMatrix where CurrentStatus='C')


		BEGIN
		
				select SecurityChargeTypeName  
				,SecurityChargeTypeAlt_key as Code
				,'CrisMacDesc'  as TableName
				from DimSecurityChargeType
				where EffectiveFromTimeKey<=@Timekey
				AND EffectiveToTimeKey>=@Timekey
				AND SecurityChargeTypeGroup ='COLLATERAL'
		END

END

GO