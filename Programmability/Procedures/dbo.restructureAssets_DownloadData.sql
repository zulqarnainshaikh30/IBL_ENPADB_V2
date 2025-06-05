SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Create PROCEDURE [dbo].[restructureAssets_DownloadData]
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

		Select @Timekey=Max(Timekey) from dbo.SysDayMatrix  
		  where  Date=cast(getdate() as Date)
		  		  PRINT @Timekey  

		--DECLARE @PageFrom INT, @PageTo INT   
  
		--SET @PageFrom = (@perPage*@Page)-(@perPage) +1  
		--SET @PageTo = @perPage*@Page 
		

IF (@UploadType='Restructure Assets Upload')

BEGIN
		
		--SELECT * FROM(
		SELECT 'Details' as TableName,
		UploadID,
		AccountID,
		RestructureFacility,
		RevisedBusinessSeg,
		DisbursementDate,
		ReferenceDate,
		InvocationDate,
		DateofConversionintoEquity,
		PrinRpymntStartDate,
		InttRpymntStartDate,
		AssetClassatRstrctr,
		IfNPANPADate,
		NPAQuarter,
		TypeofRestructuring,
		CovidMoratoriamMSME,
		CovidOTRCategory,
		BankingRelationship,
		DateofRestructuring,
		RestructuringApprovingAuth,
		DateofIstDefaultonCRILIC,
		ReportingBank,
		DateofSigningICA,
		OSasondateofRstrctr,
		POSasondateofRstrctr,
		InvestmentGrade,
		CreditProvisionRs,
		DFVProvisionRs,
		MTMProvisionRs,
		NPAIdentificationDate, -------------- newly added by kapil on 01/02/2024
		DPD_AsOnRestr        -------------- newly added by kapil on 01/02/2024




		FROM RestructureAsset_Upload_Mod
		WHERE UploadId=@ExcelUploadId
		AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey

		

	

END

END



GO