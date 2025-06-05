SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROC [dbo].[CalypsoCustomerlevelSearchdetails]
			
				@UCICID varchar(30)=''

AS
	BEGIN

Declare @Timekey int
SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

select  T.UCIfID  as UCICID
	   ,T.IssuerName as CustomerName
	   ,d.AssetClass
	   ,d.NPADate
	   ,d.SecurityValue
	   ,d.AdditionalProvision
	   ,C.ParameterName as FraudAccountFlag
	   ,d.FraudDate
	   ,'CalypsoCustomerLevelMOC' as TableName
 from  CalypsoCustomerLevelMOC D

INNER  JOIN InvestmentIssuerDetail  T  ON T.IssuerID=d.Customerid
AND  T.EffectiveFromTimeKey<=@Timekey
AND T.EffectiveToTimeKey >= @Timekey 

Left join (select parametername,parameteralt_key from Dimparameter where dimparametername='dimyesno'
AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey) C
ON D.FraudAccountFlagAlt_Key=C.ParameterAlt_Key

Where T.EffectiveFromTimeKey<=@Timekey
AND T.EffectiveToTimeKey>=@Timekey
AND T.UCIFID=@UCICID

UNION

select a.UCIC_ID  as UCICID
	   ,a.CustomerName as CustomerName
	   ,d.AssetClass
	   ,d.NPADate
	   ,d.SecurityValue
	   ,d.AdditionalProvision
	   ,C.ParameterName as FraudAccountFlag
	   ,d.FraudDate
	   ,'CalypsoCustomerLevelMOC' as TableName
 from  CalypsoCustomerLevelMOC D

inner join curdat.DerivativeDetail A
on D.Customerid=A.CustomerId
AND A.EffectiveFromTimeKey<=@Timekey
AND A.EffectiveToTimeKey>=@Timekey


Left join (select parametername,parameteralt_key from Dimparameter where dimparametername='dimyesno'
AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey) C
ON D.FraudAccountFlagAlt_Key=C.ParameterAlt_Key

Where A.EffectiveFromTimeKey<=@Timekey
AND A.EffectiveToTimeKey>=@Timekey
AND A.UCIC_ID=@UCICID


END






GO