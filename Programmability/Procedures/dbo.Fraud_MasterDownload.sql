SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[Fraud_MasterDownload]
As

BEGIN

Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

--select 
--			 MOCTypeName as FraudSource
--			 ,'FraudSource' as TableName
--			 from dimmoctype
--			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

			 
			Select
		CASE WHEN ParameterName='NO' THEN 'N' else 'Y' END RFAReportedByBank
		,'RFA_Reported_By_Bank' as Tablename 
		from DimParameter where DimParameterName='DimYesNo'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

		Select
		BankName as NameofOtherBankReportingRFA
		,'Name_of_Other_Banks_Reporting_RFA' as Tablename 
		from DimBankRP where 
		 EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

		 Select ParameterAlt_Key
		,ParameterName
		,'Provision_Proference' as Tablename 
		from DimParameter where DimParameterName='DimProvisionPreference'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

	END













GO