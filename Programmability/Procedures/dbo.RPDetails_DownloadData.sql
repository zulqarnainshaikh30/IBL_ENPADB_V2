SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[RPDetails_DownloadData]
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

IF (@UploadType='RP Details Upload')

BEGIN
		
		--SELECT * FROM(
		SELECT 'Details' as TableName,
	UploadID as [Upload ID],
CustomerID as [Customer ID],
--ReportingBank_LenderCode,
BankArrangementDesc as [Bank Arrangement],
LeadBankName as [Lead Bank Name],
ExposureBucket as [Exposure Bucket],
convert(varchar,RefrenceDate,105)[Refrence Date],
ICAStatus as [ICA Status],
NotSigingICAReason as [Reason for not signing ICA],
convert(varchar,ICAExecutionDate,105)[ICA Execution Date],
convert(varchar,NatureRPApprovalDate,105)[Approved date of Resolution Plan],
RPNature as [RP Nature] ,
OtherRPNature as [Other RP Nature],
convert(varchar,IBCFilingDate,105)[IBC Filing Date],
convert(varchar,IBCAddmissionDate,105)[IBC Addmission Date],
--convert(varchar,ActRPImpDate,105)ActRPImpDate,
--convert(varchar,OutOfDefaultDate,105)OutOfDefaultDate,
StatusOfRevisedRPDeadline as [Revised RP deadline to track reversal of provisions],
convert(varchar,RP_OutOfDateAllBanksDeadline,105)[RP_Out Of Date All Banks Deadline] 
--ImplementationStatus

		FROM RP_Portfolio_Upload_Mod
		WHERE UploadId=@ExcelUploadId
		AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey

	

END

END



GO