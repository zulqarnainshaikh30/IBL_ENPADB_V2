SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROC [dbo].[CustomerlevelSearchdetails]
			
				@CustomerID varchar(30)=''

AS
	BEGIN

Declare @Timekey int
SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

Select --'' as AccountId,
	   a.CustomerID  as CustomerID
	   ,A.CustomerName
	   ,A.AssetClass
	   ,A.NPADate
	   ,A.SecurityValue
	   ,A.AdditionalProvision
	   ,C.ParameterName as FraudAccountFlag
	   ,FraudDate
	   ,'CustomerLevelMOC' as TableName
from CustomerLevelMOC A
inner join dbo.customerBasicDetail B
on B.CustomerEntityId=A.CustomerEntityId
AND B.EffectiveFromTimeKey<=@Timekey
AND B.EffectiveToTimeKey>=@Timekey
Left join (select parametername,parameteralt_key from Dimparameter where dimparametername='dimyesno'
AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey) C
ON A.FraudAccountFlagAlt_Key=C.ParameterAlt_Key
Where A.EffectiveFromTimeKey<=@Timekey
AND A.EffectiveToTimeKey>=@Timekey
AND A.CustomerID=@CustomerID 

END




GO