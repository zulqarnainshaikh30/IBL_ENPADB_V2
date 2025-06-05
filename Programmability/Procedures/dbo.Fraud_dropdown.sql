SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[Fraud_dropdown]

  
AS
  BEGIN

  Declare @TimeKey as Int 

	Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')
		
		select ExtDate SystemDate,'SystemDate' TableName from SysDataMatrix where CurrentStatus='C'
	
	
			Select ParameterAlt_Key
		, ParameterName
		,'RFA_Reported_By_Bank' as Tablename 
		from DimParameter where DimParameterName='DimYesNo'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

		Select ParameterAlt_Key
		, ParameterName
		,'RFAReportedOtherBank' as Tablename 
		from DimParameter where DimParameterName='DimYesNo'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

		Select BankRPAlt_Key as ParameterAlt_Key
		,BankName as ParameterName
		,'Name_of_Other_Banks_Reporting_RFA' as Tablename 
		from DimBankRP where 
		 EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

		 Select ParameterAlt_Key
		,ParameterName
		,'Provision_Proference' as Tablename 
		from DimParameter where DimParameterName='DimProvisionPreference'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

		

     SELECT *, 'FraudMetaData' AS TableName FROM MetaScreenFieldDetail WHERE ScreenName='NPA Identification of Fraud Accounts'
		 and MenuId=24737

END








GO