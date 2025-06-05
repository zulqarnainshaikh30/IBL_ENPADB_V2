SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[SourceDropDown]

AS
	BEGIN

Declare @Timekey Int
Set @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') --26959

BEGIN

		Select SourceAlt_Key
		,SourceName
		,'SourceSysList' TableName
		from DIMSOURCEDB
		where EffectiveFromTimeKey<=@Timekey
		AND EffectiveToTimeKey>=@Timekey
END				

	END
GO