SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[Collateral_DownloadData]
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

IF (@UploadType='Colletral Upload')

BEGIN
		
		--SELECT * FROM(
		SELECT 'Details' as TableName,
		UploadID,
		OldCollateralID,
		TaggingLevel,
		Related_UCIC_CustomerID_AccountID,
		DistributionLevel,
		DistributionValue,
		CollateralType,
		CollateralSubType,
		CollateralOwnerType,
		CollateralOwnershipType,
		ChargeType,
		ChargeNature,
		ShareAvailableToBank,
		ShareValue,
		CollateralValueSanctionRs,
		CollateralValueNPADateRs,
		CollateralValueLastReviewRs,
		ValuationDate,
		CurrentCollateralValueRs,
		ExpiryBusinessRule

		FROM CollateralMgmtUpload_Mod
		WHERE UploadId=@ExcelUploadId
		AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey

		

	

END

END
GO