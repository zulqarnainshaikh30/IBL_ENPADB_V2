SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[Fraud_DownloadData]
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

		
  SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 

 
		  		  PRINT @Timekey  

		--DECLARE @PageFrom INT, @PageTo INT   
  
		--SET @PageFrom = (@perPage*@Page)-(@perPage) +1  
		--SET @PageTo = @perPage*@Page  

IF (@UploadType='Fraud Upload')

BEGIN
		
		--SELECT * FROM(
		SELECT Distinct A.RefCustomerAcid,
		'Details' as TableName,
		UploadID
		,SrNo
		,AccountEntityId
		,CustomerEntityId
		,RefCustomerID
		,D.ParameterName as RFA_Reported_By_Bank
		,RFA_DateReportingByBank
		,E.ParameterName as Name_of_Other_Banks_Reporting_RFA
		,RFA_OtherBankDate
		,FraudOccuranceDate
		,FraudDeclarationDate
		,FraudNature
		,FraudArea
		,CurrentAssetClassAltKey
		,F.ParameterName as Provision_Proference				
		FROM Fraud_Details_Mod A
		LEFT JOIN 
			(Select ParameterAlt_Key
		,CASE WHEN ParameterName='NO' THEN 'N' else 'Y' END ParameterName
		,'RFA_Reported_By_Bank' as Tablename 
		from DimParameter where DimParameterName='DimYesNo'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D 
		ON A.RFA_ReportingByBank = D.ParameterAlt_Key
		LEFT JOIN (Select BankRPAlt_Key as ParameterAlt_Key
		,BankName as ParameterName
		,'Name_of_Other_Banks_Reporting_RFA' as Tablename 
		from DimBankRP where 
		 EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		 )E ON A.RFA_OtherBankAltKey = E.ParameterAlt_Key
		LEFT JOIN  (
		 Select ParameterAlt_Key
		,ParameterName
		,'Provision_Proference' as Tablename 
		from DimParameter where DimParameterName='DimProvisionPreference'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		)F ON A.ProvPref = F.ParameterAlt_Key
		WHERE UploadId=@ExcelUploadId
		AND A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey


		

	

END



END












GO