SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create PROC [dbo].[GLProductCodeDroDown]

--Declare 
				@ProductName Varchar(200)

AS

	BEGIN

Declare @Timekey as Int

Set @Timekey= (select Timekey from SysDataMatrix where currentstatus='C')

	 BEGIN
		
		select A.ProductName
		,A.ProductCode
		,B.SourceAlt_Key
		,B.SourceName
		,'GLProductCodeSourceList' AS TableName
		from DimProduct A
		Inner Join DIMSOURCEDB B
		On A.SourceAlt_Key=B.SourceAlt_Key
		AND B.EffectiveFromTimeKey<=@Timekey and B.EffectiveToTimeKey>=@Timekey
		where A.EffectiveFromTimeKey<=@Timekey and A.EffectiveToTimeKey>=@Timekey
		And ProductName=@ProductName
		
		END

END
GO