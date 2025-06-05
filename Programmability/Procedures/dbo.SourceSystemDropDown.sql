SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[SourceSystemDropDown]

AS
	BEGIN

Declare @Timekey Int
Set @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C')

BEGIN

		Select SourceAlt_Key
		,SourceName
		,'SourceSystem' TableName
		from DIMSOURCEDB
		where EffectiveFromTimeKey<=@Timekey
		AND EffectiveToTimeKey>=@Timekey
END				

	END
GO