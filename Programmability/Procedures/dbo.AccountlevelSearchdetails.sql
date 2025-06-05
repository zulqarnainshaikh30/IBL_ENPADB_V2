SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

create PROC [dbo].[AccountlevelSearchdetails]
			
				@AccountID varchar(30)=''

AS
	BEGIN

Declare @Timekey int
SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

select A.CustomerACID as AccountId
	  ,A.FacilityType
	  ,A.segmentcode as Segment
	  ,B.Balance as BalancaOutstanding
	  ,B.PrincipalBalance as POS
	  ,B.InterestReceivable
	  ,B.TotalProv as NPAProvision
	  ,'OtherAccLevelMOCDetail' as TableName
 from  AccountLevelMOC D
inner join dbo.AdvAcBasicDetail A
on D.accountid=A.CustomerACID
AND A.EffectiveFromTimeKey<=@Timekey
AND A.EffectiveToTimeKey>=@Timekey
inner join dbo.AdvAcBalanceDetail B
ON A.AccountEntityId=B.AccountEntityId
AND B.EffectiveFromTimeKey<=@Timekey
AND B.EffectiveToTimeKey>=@Timekey
Where A.EffectiveFromTimeKey<=@Timekey
AND A.EffectiveToTimeKey>=@Timekey
AND A.CustomerACID=@AccountID


Select '130' as AccountId,
	  '30' as CustomerID
	   ,A.CustomerName
	   ,A.AssetClass
	   ,A.NPADate
	   ,A.SecurityValue
	   ,A.AdditionalProvision
	   ,C.ParameterName as FraudAccountFlag
	   ,FraudDate
	   ,'CustomerLevelMOC' as TableName
from CustomerLevelMOC_MOD A
left join dbo.AdvAcBasicDetail B
ON A.Customerid=B.refcustomerid
AND B.EffectiveFromTimeKey<=25992
AND B.EffectiveToTimeKey>=25992
Left join (select parametername,parameteralt_key from Dimparameter where dimparametername='dimyesno'
AND EffectiveFromTimeKey<=25999 AND EffectiveToTimeKey>=25999) C
ON A.FraudAccountFlagAlt_Key=C.ParameterAlt_Key
Where A.EffectiveFromTimeKey<=25992
AND A.EffectiveToTimeKey>=25992
AND A.CustomerID='95'

END






GO