SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[RPModuleLender_DownloadData]
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

IF (@UploadType='RPModule Lender Upload')

BEGIN
		
		--SELECT * FROM(
		SELECT 'Details' as TableName,
		UploadID,
--UCICID,
CustomerID,
--BorrowerPAN,
--BorrowerName,
LenderName,
--InDefaultDate,
convert(varchar(10),cast(InDefaultDate as date),103)InDefaultDate,
convert(varchar(10),cast(OutDefaultDate as date),103) OutDefaultDate
--OutDefaultDate

		FROM RPModuleLender_Mod
		WHERE UploadId=@ExcelUploadId
		AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey

		

	

END

END


GO