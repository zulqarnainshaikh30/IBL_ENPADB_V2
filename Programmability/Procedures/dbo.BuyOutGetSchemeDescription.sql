SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



--CollateralMasterDownload
Create PROC [dbo].[BuyOutGetSchemeDescription]
@SchemeCode Varchar(500)=''
As

BEGIN

Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

	select ProductName as SchemeCodeDescription
	from dimproduct


	where ProductCode=@SchemeCode AND SourceAlt_Key=1 AND
	EffectiveFromTimeKey<=@TimeKey
	AND EffectiveToTimeKey >=@TimeKey

	--select  ParameterAlt_Key
	--	,ParameterName
	--	,'SeniorityOfChargeMaster' as TableName 
	--	from DimParameter A where DimParameterName='DimSeniorityOfCharge'
	--	AND A.EffectiveFromTimeKey<=@TimeKey
	--AND A.EffectiveToTimeKey >=@TimeKey

		

		
			
		
			
			


	END



GO