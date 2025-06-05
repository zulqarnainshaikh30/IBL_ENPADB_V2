SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[ProvisionoCategoryDropdown]

AS

BEGIN

Declare @Timekey Int
Set @Timekey=(Select TimeKey from SysDataMatrix where CurrentStatus='C')


		BEGIN
		
				select Parametername,
				ParameterAlt_Key,
				'CategoryType' TableName
				from DimParameter
				where 
				DimParameterName='Category Type'
				AND EffectiveFromTimeKey<=@Timekey
				AND EffectiveToTimeKey>=@Timekey
		END

END

GO