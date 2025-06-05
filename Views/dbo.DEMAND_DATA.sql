SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





create VIEW [dbo].[DEMAND_DATA]

AS
SELECT * FROM AdvAcDemandDetail WHERE ACTYPE IN('TLDL','CCOD')
UNION
SELECT 
EntityKey
,BranchCode
,AccountEntityID
,DemandType
,DemandDate
,DemandOverDueDate
,DemandAmt
,RecDate
,RecAdjDate
,RecAmount
,BalanceDemand
,DmdSchNumber
,RefSystemACID
,'KCC' AcType
,DmdGenNum
,TxnTag_AltKey
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,NULL DMD_VOUCH_DATE
,NULL DMD_VOUCH_AMT

 FROM CURDAT.AdvAcDemandDetail_KCC





GO