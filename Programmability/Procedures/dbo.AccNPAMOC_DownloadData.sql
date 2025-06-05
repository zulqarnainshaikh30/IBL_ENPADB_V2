SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[AccNPAMOC_DownloadData]
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

IF (@UploadType='Account MOC Upload')

BEGIN
		
		--SELECT * FROM(
		SELECT  Distinct
	        UploadID,
		    AccountID,
		   'Details' as TableName,

		
			--,POS
			--InterestReceivable,
			
			AdditionalProvisionAbsolute
			,AddlProvPer
			--,RestructureFlag
			--,A.RestructureDate
			--,FITLFlag
			--,DFVAmount
			--,RePossessionFlag
			--,A.RePossessionDate
			--,InherentWeaknessFlag
			--,InherentWeaknessDate
			--,SARFAESIFlag
			--,A.SARFAESIDate
			--,UnusualBounceFlag
			--,A.UnusualBounceDate
			--,UnclearedEffectsFlag
			--,UnclearedEffectsDate
			--,FraudAccountFlag
			--,A.FraudDate
			,MOCSource
			,A.MOCReason
			,A.MOCType
		    --,A.FlgTwo
            --,A.TwoDate
            --,A.TwoAmount
			,A.MOC_Reason_Remark              --Added by kapil 28/11/2023

	
		FROM AccountLevelMOC_Mod A
		--INNER JOIN PRO.AccountCal_Hist B ON A.AccountID=B.CustomerAcID
		WHERE UploadId=@ExcelUploadId
		AND A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey


		


		

	

END



END



GO