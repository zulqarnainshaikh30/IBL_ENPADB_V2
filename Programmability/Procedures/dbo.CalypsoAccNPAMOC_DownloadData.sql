SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[CalypsoAccNPAMOC_DownloadData]
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

	    SET DATEFORMAT DMY;

		
  --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 

  --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 

  SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 

		  		  PRINT @Timekey  

		--DECLARE @PageFrom INT, @PageTo INT   
  
		--SET @PageFrom = (@perPage*@Page)-(@perPage) +1  
		--SET @PageTo = @perPage*@Page  

IF (@UploadType='Calypso Account MOC Upload')

BEGIN
		
		--SELECT * FROM(
		SELECT  Distinct AccountID AS [Investment ID/Derivative Ref No]
		--'Details' as TableName,
		
			
			,AdditionalProvisionAbsolute AS [Additional Provision - Absolute in Rs.]
			
			
			,CONVERT(VARCHAR(10),A.FraudDate,103) AS [Fraud Date]
			
		    --,A.FlgTwo
               ,CONVERT(VARCHAR(10),A.TwoDate,103)AS [Tw o Date]
			
			,MOCSource AS [MOC Source]
			,A.MOCReason AS [MOC Reason]
            

	
		FROM CalypsoAccountLevelMOC_Mod A
		--INNER JOIN PRO.AccountCal_Hist B ON A.AccountID=B.CustomerAcID


		WHERE a.UploadId=@ExcelUploadId
		AND A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey


		


		

	

END



END




GO