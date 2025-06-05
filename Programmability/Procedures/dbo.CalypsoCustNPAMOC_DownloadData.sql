SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[CalypsoCustNPAMOC_DownloadData]
	@Timekey INT
	,@UserLoginId VARCHAR(100)
	,@ExcelUploadId INT
	,@UploadType VARCHAR(50)
	--,@Page SMALLINT =1     
 --   ,@perPage INT = 30000   
AS

----DECLARE @Timekey INT=49999
----	,@UserLoginId VARCHAR(100)='FNASUPERADMIN'
----	,@ExcelUploadId INT=4
----	,@UploadType VARCHAR(50)='Interest reversal'

BEGIN
		SET NOCOUNT ON;

		
  --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 

  --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 

  
  
SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 

		  		  PRINT @Timekey  

		--DECLARE @PageFrom INT, @PageTo INT   
  
		--SET @PageFrom = (@perPage*@Page)-(@perPage) +1  
		--SET @PageTo = @perPage*@Page  

IF (@UploadType='Calypso Customer MOC Upload')



BEGIN

IF EXISTS (select 1 FROM CalypsoCustomerLevelMOC_Mod A
			INNER JOIN InvestmentIssuerDetail B ON A.UCIFID=B.UCIFID
		WHERE UploadId=@ExcelUploadId
		AND A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey
		AND B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey)
		BEGIN
		--SELECT * FROM(
		SELECT Distinct A.UCIFID AS UCICID,'Details' as TableName,
		UploadID,
		
		B.IssuerName as CustomerName,
		A.AssetClass,
		TRY_CAST(NPADate as varchar)as NPADate,
		--A.SecurityValue,
		AdditionalProvision,
		A.MOCType,
		A.MOCReason,
		TRY_CAST(A.MOCDate as varchar)as MOCDate,
		--MOCBy,
		MOCSource
	
		FROM CalypsoCustomerLevelMOC_Mod A
			INNER JOIN InvestmentIssuerDetail B ON A.UCIFID=B.UCIFID
		WHERE UploadId=@ExcelUploadId
		AND A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey
		AND B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey
		END

		ELSE

		BEGIN
		SELECT Distinct A.UCIFID AS UCICID,'Details' as TableName,
		UploadID,
		
		B.CustomerName,
		A.AssetClass,
		TRY_CAST(NPADate as varchar) as NPADate,
		--SecurityValue,
		AdditionalProvision,
		A.MOCType,
		A.MOCReason,
		TRY_CAST(A.MOCDate as varchar) as MOCDate,
		--MOCBy,
		MOCSource
	
		FROM CalypsoCustomerLevelMOC_Mod A
			INNER JOIN curdat.DerivativeDetail B ON A.UCIFID=B.UCIC_ID
		WHERE UploadId=@ExcelUploadId
		AND A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey
		AND B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey
		END

	

END



END




GO