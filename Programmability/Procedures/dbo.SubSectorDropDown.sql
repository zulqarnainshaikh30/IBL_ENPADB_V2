SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[SubSectorDropDown]

AS

BEGIN

Declare @Timekey Int
Set @Timekey=(Select TimeKey from SysDataMatrix where CurrentStatus='C')


		BEGIN
		
				select SubSectorName 
				,SubSectorAlt_key as Code
				,'CrisMacDesc'  as TableName
				from DimSubSector
				where EffectiveFromTimeKey<=@Timekey
				AND EffectiveToTimeKey>=@Timekey
		END

END

GO