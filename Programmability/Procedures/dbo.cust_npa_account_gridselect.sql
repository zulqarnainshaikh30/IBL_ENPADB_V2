SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



--exec cust_npa_account_gridselect @AccountId=N'247'


CREATE PROC [dbo].[cust_npa_account_gridselect] 
@AccountId varchar(30)   
AS



Declare @TimeKey as Int
,@Customerid varchar(max)--='9987888'
,@OperationFlag int=1
	 SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 

  SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey)



IF(@OperationFlag  in ( 1,16))
             BEGIN

IF (OBJECT_ID('tempdb..#LABEL') IS NOT NULL)
	DROP TABLE #LABEL


SELECT * INTO #LABEL FROM
(	
SELECT  'BalanceOSPOS'                             AS	LabeL,  01	AS	RowID	UNION ALL 
SELECT	'BalanceOSInttReceivable'	              AS	LabeL,  02	AS	RowID	UNION ALL
SELECT	'RestructureFlag'				              AS	LabeL,  03	AS	RowID	UNION ALL
SELECT	'RestructureDate'				              AS	LabeL,  04	AS	RowID	UNION ALL																	
SELECT	'FITLFlag'						              AS	LabeL,  05	AS	RowID	UNION ALL															          
SELECT	'DFVAmt'						              AS	LabeL,  06	AS	RowID	UNION ALL
SELECT	'RePossessionFlag'			              AS	LabeL,  07	AS	RowID	UNION ALL
SELECT	'RePossessionDate'			              AS	LabeL,  08	AS	RowID	UNION ALL
SELECT	'InherentWeaknessFlag'		              AS	LabeL,  09	AS	RowID	UNION ALL															          
SELECT	'InherentWeaknessDate'		              AS	LabeL,  10	AS	RowID	UNION ALL
SELECT	'SARFAESIFlag'				                  AS	LabeL,  11	AS	RowID	UNION ALL
SELECT	'SARFAESIDate'			                      AS	LabeL,  12	AS	RowID	UNION ALL
SELECT	'UnusualBounceFlag'			              AS	LabeL,  13	AS	RowID	UNION ALL															          
SELECT	'UnusualBounceDate'		                  AS	LabeL,  14	AS	RowID	UNION ALL
SELECT	'UnclearedEffectFlag'	                      AS	LabeL,  15	AS	RowID	UNION ALL
SELECT	'UnclearedEffectDate'			              AS	LabeL,  16	AS	RowID	UNION ALL
SELECT	'AdditionalProvisionCustomerLevel'	  AS	LabeL,  17	AS	RowID	UNION ALL															          
SELECT	'AdditionalProvisionAbsolute'		      AS	LabeL,  18	AS	RowID	UNION ALL
SELECT	'MOCReason'				                  AS	LabeL,  19	AS	RowID	UNION ALL
--SELECT 'FraudAccountFlagAlt_Key'				AS Label, 20 AS ROWID UNION ALL
SELECT 'FraudAccountFlag'					AS Label, 20 AS ROWID UNION ALL	
SELECT 'FraudDate'							AS Label, 21 AS ROWID


) A 

--select * from #LABEL
OPTION(RECOMPILE)
-----==========================================

IF (OBJECT_ID('tempdb..#PostMOC') IS NOT NULL)
DROP TABLE #PostMOC


select 
A.Balance   AS 'BalanceOSPOS'
,A.unserviedint  AS 'BalanceOSInttReceivable'
--,A.RestructureFlagAlt_Key
,A.FlgRestructure as RestructureFlag
,A.RestructureDate
--,A.FITLFlagAlt_Key
,A.FLGFITL as FITLFlag
,A.DFVAmt as DFVAmt
--,A.RePossessionFlagAlt_Key
,A.RePossession as RePossessionFlag
,A.RePossessionDate 
--,A.InherentWeaknessFlagAlt_Key
,A.WeakAccount as InherentWeaknessFlag
,A.WeakAccountDate as 'InherentWeaknessDate'
--,A.SARFAESIFlagAlt_Key
,A.Sarfaesi as SARFAESIFlag
,A.SARFAESIDate as 'SARFAESIDate'
--,A.UnusualBounceFlagAlt_Key
,A.FlgUnusualBounce as UnusualBounceFlag
,A.UnusualBounceDate as 'UnusualBounceDate'
--,A.UnclearedEffectsFlagAlt_Key
,A.FlgUnClearedEffect as UnclearedEffectFlag
,A.UnclearedEffectDate as 'UnclearedEffectDate'
,NULL as AdditionalProvisionCustomerlevel
,NULL as AdditionalProvisionAbsolute
,A.MOCReason
--,A.FraudAccountFlagAlt_Key
,A.FlgFraud as FraudAccountFlag	
,A.FraudDate as  FraudDate
  
into #PostMOC
from pro.AccountCal_Hist A


--Inner Join (Select ParameterAlt_Key,ParameterName,'RestructureFlag' as Tablename 
--						from DimParameter where DimParameterName='DimYN'
--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
--						ON B.ParameterAlt_Key=A.RestructureFlagAlt_Key

--						Inner Join (Select ParameterAlt_Key,ParameterName,'FITLFlag' as Tablename 
--						from DimParameter where DimParameterName='DimYN'
--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)C
--						ON C.ParameterAlt_Key=A.FITLFlagAlt_Key

--						Inner Join (Select ParameterAlt_Key,ParameterName,'RePossessionFlag' as Tablename 
--						from DimParameter where DimParameterName='DimYN'
--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D
--						ON D.ParameterAlt_Key=A.RePossessionFlagAlt_Key

--						left join (select CustomerID,StatusType,StatusDate, 'RePossessionDate' as TableName
--						from ExceptionFinalStatusType where StatusType like '%Reposse%'
--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) I
--						ON A.CustomerID=I.CustomerID

--						Inner Join (Select ParameterAlt_Key,ParameterName,'InherentWeaknessFlag' as Tablename 
--						from DimParameter where DimParameterName='DimYN'
--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)E
--						ON E.ParameterAlt_Key=A.InherentWeaknessFlagAlt_Key

--						left join (select CustomerID,StatusType,StatusDate, 'InherentWeaknessDate' as TableName
--						from ExceptionFinalStatusType where StatusType like '%Inherent%'
--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) J
--						ON A.CustomerID=J.CustomerID

--						Inner Join (Select ParameterAlt_Key,ParameterName,'SARFAESIFlag' as Tablename 
--						from DimParameter where DimParameterName='DimYN'
--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)F
--						ON F.ParameterAlt_Key=A.SARFAESIFlagAlt_Key

--						left join (select CustomerID,StatusType,StatusDate, 'SARFAESIDate' as TableName
--						from ExceptionFinalStatusType where StatusType like '%SARFAESI%'
--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) K
--						ON A.CustomerID=K.CustomerID

--						Inner Join (Select ParameterAlt_Key,ParameterName,'UnusualBounceFlag' as Tablename 
--						from DimParameter where DimParameterName='DimYN'
--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)G
--						ON G.ParameterAlt_Key=A.UnusualBounceFlagAlt_Key

--						left join (select CustomerID,StatusType,StatusDate, 'UnusualBounceDate' as TableName
--						from ExceptionFinalStatusType where StatusType like '%Unusual%'
--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) L
--						ON A.CustomerID=L.CustomerID

--						Inner Join (Select ParameterAlt_Key,ParameterName,'UnclearedEffectsFlag' as Tablename 
--						from DimParameter where DimParameterName='DimYN'
--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
--						ON H.ParameterAlt_Key=A.UnclearedEffectsFlagAlt_Key

--						left join (select CustomerID,StatusType,StatusDate, 'UnclearedEffectsDate' as TableName
--						from ExceptionFinalStatusType where StatusType like '%Uncleared%'
--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) M
--						ON A.CustomerID=M.CustomerID
						
--						left join AdvAcBalanceDetail ACBAL ON ACBAL.RefSystemAcId= A.Accountid
--						and ACBAL.EffectiveFromTimeKey<=@Timekey and ACBAL.EffectiveToTimeKey>=@Timekey
--						left JOIN (	SELECT CustomerID,
--												STATUSTYPE, 
--												STATUSDATE 
--										FROM ExceptionFinalStatusType 
--										WHERE STATUSTYPE like'%FRAUD%'
--										AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
--									) X
--									ON A.CustomerID=X.CustomerID

--									inner join (select ParameterAlt_Key,ParameterName,'Fraud' as TableName
--									from DimParameter where DimParameterName = 'DimYN'
--									AND EffectiveFromTimeKey <=@TimeKey and EffectiveToTimeKey>=@TimeKey)W
--									ON W.ParameterAlt_Key=A.FraudAccountFlagAlt_Key

--select 
--case when ACBAL.MocStatus='Y' then ACBAL.Balance end  AS 'BalanceOSPOS'
----,case when PREACBAL.MocStatus='Y' then PREACBAL.Balance end  AS 'post_Balance o/s POS'
--,case when ACBAL.MocStatus='Y' then ACBAL.InterestReceivable end  AS 'BalanceOSInttReceivable'
----,case when PREACBAL.MocStatus='Y' then ACBAL.InterestReceivable end  AS 'Post_Balance o/s Intt.Receivable'
----,ACBAL.InterestReceivable AS 'Balance o/s Intt.Receivable'
--,'Y' AS 'RestructureFlag'
--,NULL AS 'RestructureDate'
--,ACAL.FlgFITL AS 'FITLFlag'
--,ACAL.DFVAmt AS 'DFVAmt'
--,CASE WHEN EFT.StatusType='Repossesed' THEN 'Repossesed' END  AS 'RePossessionFlag'
--,CASE WHEN EFT.StatusType='Repossesed'  THEN StatusDate  END AS 'RePossessionDate'
--,CASE WHEN EFT.StatusType='Inherent Weakness' THEN 'Inherent Weakness'  END AS 'InherentWeaknessFlag'
--,CASE WHEN EFT.StatusType='Inherent Weakness'  THEN StatusDate  END AS 'InherentWeaknessDate'

--,CASE WHEN EFT.StatusType='SARFAESI' THEN 'SARFAESI'  END AS 'SARFAESIFlag'
--,CASE WHEN EFT.StatusType='SARFAESI'  THEN StatusDate ELSE NULL END  AS 'SARFAESIDate'

--,CASE WHEN EFT.StatusType='Unusual Bounce' THEN 'Unusual Bounce' ELSE '' END AS 'UnusualBounceFlag'
--,CASE WHEN EFT.StatusType='Unusual Bounce'  THEN CAST(StatusDate AS Date) ELSE NULL END  AS 'UnusualBounceDate'

--,CASE WHEN EFT.StatusType='Uncleared Effect' THEN 'Uncleared Effect' ELSE '' END AS 'UnclearedEffectFlag'
--,CASE WHEN EFT.StatusType='Uncleared Effect'  THEN CAST(StatusDate AS Date) ELSE NULL END  AS 'UnclearedEffectDate'

--,NULL AS 'AdditionalProvisionCustomerLevel'
--,NULL AS 'AdditionalProvisionAbsolute'
--,NULL AS 'MOCReason'

--into #PostMOC
--From AdvAcBasicDetail ACBD
--INNER join AdvAcBalanceDetail ACBAL ON ACBAL.AccountEntityId= ACBD.AccountEntityId
--                                    and ACBD.EffectiveFromTimeKey<=@Timekey and ACBD.EffectiveToTimeKey>=@Timekey
--									  and ACBAL.EffectiveFromTimeKey<=@Timekey and ACBAL.EffectiveToTimeKey>=@Timekey
----INNER join premoc.AdvAcBalanceDetail PREACBAL ON PREACBAL.AccountEntityId= ACBD.AccountEntityId
----                                    and PREACBAL.EffectiveFromTimeKey<=@Timekey and PREACBAL.EffectiveToTimeKey>=@Timekey
--left JOIN CustomerBasicDetail CBD ON CBD.CustomerEntityId=ACBD.CustomerEntityId
--                                    and CBD.EffectiveFromTimeKey<=@Timekey and CBD.EffectiveToTimeKey>=@Timekey
----left JOIN ExceptionalDegrationDetail ED ON ED.CustomerID=CBD.CustomerId
----                                     and ED.EffectiveFromTimeKey<=@Timekey and ED.EffectiveToTimeKey>=@Timekey
--left JOIN ExceptionFinalStatusType EFT ON EFT.CustomerID=CBD.CustomerID
--                                  and EFT.EffectiveFromTimeKey<=@Timekey and EFT.EffectiveToTimeKey>=@Timekey
--left JOIN PRO.ACCOUNTCAL  ACAL  ON CBD.CustomerID=ACAL.RefCustomerID
WHERE A.CustomerAcID=@AccountId
and A.EffectiveFromTimeKey<=@Timekey and A.EffectiveToTimeKey>=@Timekey
--select * from #FID1
OPTION(RECOMPILE)


IF (OBJECT_ID('tempdb..#PreMOC') IS NOT NULL)
DROP TABLE #PreMOC

select 
A.Balance   AS 'BalanceOSPOS'
,A.unserviedint  AS 'BalanceOSInttReceivable'
--,A.RestructureFlagAlt_Key
,A.FlgRestructure as RestructureFlag
,A.RestructureDate
--,A.FITLFlagAlt_Key
,A.FLGFITL as FITLFlag
,A.DFVAmt as DFVAmt
--,A.RePossessionFlagAlt_Key
,A.RePossession as RePossessionFlag
,A.RePossessionDate 
--,A.InherentWeaknessFlagAlt_Key
,A.WeakAccount as InherentWeaknessFlag
,A.WeakAccountDate as 'InherentWeaknessDate'
--,A.SARFAESIFlagAlt_Key
,A.Sarfaesi as SARFAESIFlag
,A.SARFAESIDate as 'SARFAESIDate'
--,A.UnusualBounceFlagAlt_Key
,A.FlgUnusualBounce as UnusualBounceFlag
,A.UnusualBounceDate as 'UnusualBounceDate'
--,A.UnclearedEffectsFlagAlt_Key
,A.FlgUnClearedEffect as UnclearedEffectFlag
,A.UnclearedEffectDate as 'UnclearedEffectDate'
,NULL as AdditionalProvisionCustomerlevel
,NULL as AdditionalProvisionAbsolute
,A.MOCReason
  --,A.FraudAccountFlagAlt_Key
,A.FlgFraud as FraudAccountFlag	
,A.FraudDate as  FraudDate
into #PreMOC
from [PreMoc].[AccountCal]  A

--Inner Join (Select ParameterAlt_Key,ParameterName,'RestructureFlag' as Tablename 
--						from DimParameter where DimParameterName='DimYN'
--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
--						ON B.ParameterAlt_Key=A.RestructureFlagAlt_Key

--						Inner Join (Select ParameterAlt_Key,ParameterName,'FITLFlag' as Tablename 
--						from DimParameter where DimParameterName='DimYN'
--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)C
--						ON C.ParameterAlt_Key=A.FITLFlagAlt_Key

--						Inner Join (Select ParameterAlt_Key,ParameterName,'RePossessionFlag' as Tablename 
--						from DimParameter where DimParameterName='DimYN'
--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D
--						ON D.ParameterAlt_Key=A.RePossessionFlagAlt_Key

--						left join (select CustomerID,StatusType,StatusDate, 'RePossessionDate' as TableName
--						from ExceptionFinalStatusType where StatusType like '%Reposse%'
--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) I
--						ON A.CustomerID=I.CustomerID

--						Inner Join (Select ParameterAlt_Key,ParameterName,'InherentWeaknessFlag' as Tablename 
--						from DimParameter where DimParameterName='DimYN'
--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)E
--						ON E.ParameterAlt_Key=A.InherentWeaknessFlagAlt_Key

--						left join (select CustomerID,StatusType,StatusDate, 'InherentWeaknessDate' as TableName
--						from ExceptionFinalStatusType where StatusType like '%Inherent%'
--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) J
--						ON A.CustomerID=J.CustomerID

--						Inner Join (Select ParameterAlt_Key,ParameterName,'SARFAESIFlag' as Tablename 
--						from DimParameter where DimParameterName='DimYN'
--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)F
--						ON F.ParameterAlt_Key=A.SARFAESIFlagAlt_Key

--						left join (select CustomerID,StatusType,StatusDate, 'SARFAESIDate' as TableName
--						from ExceptionFinalStatusType where StatusType like '%SARFAESI%'
--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) K
--						ON A.CustomerID=K.CustomerID

--						Inner Join (Select ParameterAlt_Key,ParameterName,'UnusualBounceFlag' as Tablename 
--						from DimParameter where DimParameterName='DimYN'
--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)G
--						ON G.ParameterAlt_Key=A.UnusualBounceFlagAlt_Key

--						left join (select CustomerID,StatusType,StatusDate, 'UnusualBounceDate' as TableName
--						from ExceptionFinalStatusType where StatusType like '%Unusual%'
--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) L
--						ON A.CustomerID=L.CustomerID

--						Inner Join (Select ParameterAlt_Key,ParameterName,'UnclearedEffectsFlag' as Tablename 
--						from DimParameter where DimParameterName='DimYN'
--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
--						ON H.ParameterAlt_Key=A.UnclearedEffectsFlagAlt_Key

--						left join (select CustomerID,StatusType,StatusDate, 'UnclearedEffectsDate' as TableName
--						from ExceptionFinalStatusType where StatusType like '%Uncleared%'
--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) M
--						ON A.CustomerID=M.CustomerID
						
--						left join AdvAcBalanceDetail ACBAL ON ACBAL.RefSystemAcId= A.Accountid
--						and ACBAL.EffectiveFromTimeKey<=@Timekey and ACBAL.EffectiveToTimeKey>=@Timekey
--						left JOIN (	SELECT CustomerID,
--												STATUSTYPE, 
--												STATUSDATE 
--										FROM ExceptionFinalStatusType 
--										WHERE STATUSTYPE like'%FRAUD%'
--										AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
--									) X
--									ON A.CustomerID=X.CustomerID

--									inner join (select ParameterAlt_Key,ParameterName,'Fraud' as TableName
--									from DimParameter where DimParameterName = 'DimYN'
--									AND EffectiveFromTimeKey <=@TimeKey and EffectiveToTimeKey>=@TimeKey)W
--									ON W.ParameterAlt_Key=A.FraudAccountFlagAlt_Key


--select 
--case when ISNULL(ACBAL.MocStatus,'N')='N' then ACBAL.Balance end  AS 'BalanceOSPOS'
----,case when PREACBAL.MocStatus='Y' then PREACBAL.Balance end  AS 'post_Balance o/s POS'
--,case when ISNULL(ACBAL.MocStatus,'N')='N' then ACBAL.IntReverseAmt end  AS 'BalanceOSInttReceivable'  --InterestReceivable column not available
----,case when PREACBAL.MocStatus='Y' then ACBAL.InterestReceivable end  AS 'Post_Balance o/s Intt.Receivable'
----,ACBAL.InterestReceivable AS 'Balance o/s Intt.Receivable'
--,'Y' AS 'RestructureFlag'
--,NULL AS 'RestructureDate'
--,ACAL.FlgFITL AS 'FITLFlag'
--,ACAL.DFVAmt AS 'DFVAmt'
--,CASE WHEN EFT.StatusType='Repossesed' THEN 'Repossesed' END  AS 'RePossessionFlag'
--,CASE WHEN EFT.StatusType='Repossesed'  THEN StatusDate  END AS 'RePossessionDate'
--,CASE WHEN EFT.StatusType='Inherent Weakness' THEN 'Inherent Weakness'  END AS 'InherentWeaknessFlag'
--,CASE WHEN EFT.StatusType='Inherent Weakness'  THEN StatusDate  END AS 'InherentWeaknessDate'

--,CASE WHEN EFT.StatusType='SARFAESI' THEN 'SARFAESI'  END AS 'SARFAESIFlag'
--,CASE WHEN EFT.StatusType='SARFAESI'  THEN StatusDate ELSE NULL END  AS 'SARFAESIDate'

--,CASE WHEN EFT.StatusType='Unusual Bounce' THEN 'Unusual Bounce' ELSE '' END AS 'UnusualBounceFlag'
--,CASE WHEN EFT.StatusType='Unusual Bounce'  THEN CAST(StatusDate AS Date) ELSE NULL END  AS 'UnusualBounceDate'

--,CASE WHEN EFT.StatusType='Uncleared Effect' THEN 'Uncleared Effect' ELSE '' END AS 'UnclearedEffectFlag'
--,CASE WHEN EFT.StatusType='Uncleared Effect'  THEN CAST(StatusDate AS Date) ELSE NULL END  AS 'UnclearedEffectDate'

--,NULL AS 'AdditionalProvisionCustomerLevel'
--,NULL AS 'AdditionalProvisionAbsolute'
--,NULL AS 'MOCReason'

--into #PreMOC
--From AdvAcBasicDetail ACBD
--/*
--INNER join PreMoc.AdvAcBalanceDetail ACBAL ON ACBAL.AccountEntityId= ACBD.AccountEntityId
--                                    and ACBD.EffectiveFromTimeKey<=@Timekey and ACBD.EffectiveToTimeKey>=@Timekey
--									and ACBAL.EffectiveFromTimeKey<=@Timekey and ACBAL.EffectiveToTimeKey>=@Timekey

--left JOIN premoc.CustomerBasicDetail CBD ON CBD.CustomerEntityId=ACBD.CustomerEntityId
--                                    and CBD.EffectiveFromTimeKey<=@Timekey and CBD.EffectiveToTimeKey>=@Timekey
--left JOIN ExceptionalDegrationDetail ED ON ED.CustomerID=CBD.CustomerId
--                                     and ED.EffectiveFromTimeKey<=@Timekey and ED.EffectiveToTimeKey>=@Timekey
--left JOIN ExceptionFinalStatusType EFT ON EFT.CustomerID=ED.CustomerID
--                                  and EFT.EffectiveFromTimeKey<=@Timekey and EFT.EffectiveToTimeKey>=@Timekey
--INNER JOIN PRO.ACCOUNTCAL  ACAL  ON CBD.CustomerID=ACAL.RefCustomerID
----WHERE CBD.CustomerID='9987888' 
--*/
--INNER join AdvAcBalanceDetail ACBAL ON ACBAL.AccountEntityId= ACBD.AccountEntityId
--                                    and ACBD.EffectiveFromTimeKey<=@Timekey and ACBD.EffectiveToTimeKey>=@Timekey
--									and ACBAL.EffectiveFromTimeKey<=@Timekey and ACBAL.EffectiveToTimeKey>=@Timekey
----INNER join premoc.AdvAcBalanceDetail PREACBAL ON PREACBAL.AccountEntityId= ACBD.AccountEntityId
----                                    and PREACBAL.EffectiveFromTimeKey<=@Timekey and PREACBAL.EffectiveToTimeKey>=@Timekey
--left JOIN CustomerBasicDetail CBD ON CBD.CustomerEntityId=ACBD.CustomerEntityId
--                                    and CBD.EffectiveFromTimeKey<=@Timekey and CBD.EffectiveToTimeKey>=@Timekey
----left JOIN ExceptionalDegrationDetail ED ON ED.CustomerID=CBD.CustomerId
----                                     and ED.EffectiveFromTimeKey<=@Timekey and ED.EffectiveToTimeKey>=@Timekey
--left JOIN ExceptionFinalStatusType EFT ON EFT.CustomerID=CBD.CustomerID
--                                  and EFT.EffectiveFromTimeKey<=@Timekey and EFT.EffectiveToTimeKey>=@Timekey
--left JOIN PRO.ACCOUNTCAL  ACAL  ON CBD.CustomerID=ACAL.RefCustomerID
WHERE A.CustomerAcID=@AccountId
and A.EffectiveFromTimeKey<=@Timekey and A.EffectiveToTimeKey>=@Timekey
OPTION(RECOMPILE)

--select * from #PostMOC
--select * from #PreMOC

SELECT

 --RowID,
Label      AS Description ,
	   CASE
		    WHEN #LABEL.RowID=01  THEN cast(#PostMOC.[BalanceOSPOS] AS varchar(30))
            WHEN #LABEL.RowID=02  THEN cast(#PostMOC.[BalanceOSInttReceivable] AS varchar(30))
			WHEN #LABEL.RowID=03  THEN cast(#PostMOC.[RestructureFlag] AS varchar(30))
			WHEN #LABEL.RowID=04  THEN cast(#PostMOC.[RestructureDate] AS varchar(30))
			WHEN #LABEL.RowID=05  THEN cast(#PostMOC.[FITLFlag] AS varchar(30))
			WHEN #LABEL.RowID=06  THEN cast(#PostMOC.[DFVAmt] AS varchar(30))
			WHEN #LABEL.RowID=07  THEN cast(#PostMOC.[RePossessionFlag] AS varchar(30))
			WHEN #LABEL.RowID=08  THEN cast(#PostMOC.[RePossessionDate] AS varchar(30))
			WHEN #LABEL.RowID=09  THEN cast(#PostMOC.[InherentWeaknessFlag] AS varchar(30))
			WHEN #LABEL.RowID=10  THEN cast(#PostMOC.[InherentWeaknessDate] AS varchar(30))
			WHEN #LABEL.RowID=11  THEN cast(#PostMOC.[SARFAESIFlag] AS varchar(30))
			WHEN #LABEL.RowID=12  THEN cast(#PostMOC.[SARFAESIDate] AS varchar(30))
			WHEN #LABEL.RowID=13  THEN cast(#PostMOC.[UnusualBounceFlag] AS varchar(30))
			WHEN #LABEL.RowID=14  THEN cast(#PostMOC.[UnusualBounceDate] AS varchar(30))
			WHEN #LABEL.RowID=15  THEN cast(#PostMOC.[UnclearedEffectFlag] AS varchar(30))
			WHEN #LABEL.RowID=16  THEN cast(#PostMOC.[UnclearedEffectDate] AS varchar(30)) 
			WHEN #LABEL.RowID=17  THEN cast(#PostMOC.[AdditionalProvisionCustomerLevel] AS varchar(30))
			WHEN #LABEL.RowID=18  THEN cast(#PostMOC.[AdditionalProvisionAbsolute] AS varchar(30))
			WHEN #LABEL.RowID=19  THEN cast(#PostMOC.[MOCReason] AS varchar(30))
			WHEN #LABEL.RowID=20  THEN cast(#PostMOC.[FraudAccountFlag] AS varchar(30))
			WHEN #LABEL.RowID=21  THEN cast(#PostMOC.[FraudDate] AS varchar(30))

		
		END			'PostMocStatus'

	   ,CASE
		    WHEN #LABEL.RowID=01  THEN cast(#PreMOC.[BalanceOSPOS] AS varchar(30))
            WHEN #LABEL.RowID=02  THEN cast(#PreMOC.[BalanceOSInttReceivable] AS varchar(30))
			WHEN #LABEL.RowID=03  THEN cast(#PreMOC.[RestructureFlag] AS varchar(30))
			WHEN #LABEL.RowID=04  THEN cast(#PreMOC.[RestructureDate] AS varchar(30))
			WHEN #LABEL.RowID=05  THEN cast(#PreMOC.[FITLFlag] AS varchar(30))
			WHEN #LABEL.RowID=06  THEN cast(#PreMOC.[DFVAmt] AS varchar(30))
			WHEN #LABEL.RowID=07  THEN cast(#PreMOC.[RePossessionFlag] AS varchar(30))
			WHEN #LABEL.RowID=08  THEN cast(#PreMOC.[RePossessionDate] AS varchar(30))
			WHEN #LABEL.RowID=09  THEN cast(#PreMOC.[InherentWeaknessFlag] AS varchar(30))
			WHEN #LABEL.RowID=10  THEN cast(#PreMOC.[InherentWeaknessDate] AS varchar(30))
			WHEN #LABEL.RowID=11  THEN cast(#PreMOC.[SARFAESIFlag] AS varchar(30))
			WHEN #LABEL.RowID=12  THEN cast(#PreMOC.[SARFAESIDate] AS varchar(30))
			WHEN #LABEL.RowID=13  THEN cast(#PreMOC.[UnusualBounceFlag] AS varchar(30))
			WHEN #LABEL.RowID=14  THEN cast(#PreMOC.[UnusualBounceDate] AS varchar(30))
			WHEN #LABEL.RowID=15  THEN cast(#PreMOC.[UnclearedEffectFlag] AS varchar(30))
			WHEN #LABEL.RowID=16  THEN cast(#PreMOC.[UnclearedEffectDate] AS varchar(30)) 
			WHEN #LABEL.RowID=17  THEN cast(#PreMOC.[AdditionalProvisionCustomerLevel] AS varchar(30))
			WHEN #LABEL.RowID=18  THEN cast(#PreMOC.[AdditionalProvisionAbsolute] AS varchar(30))
			WHEN #LABEL.RowID=19  THEN cast(#PreMOC.[MOCReason] AS varchar(30))
			WHEN #LABEL.RowID=20  THEN cast(#PostMOC.[FraudAccountFlag] AS varchar(30))
			WHEN #LABEL.RowID=21  THEN cast(#PostMOC.[FraudDate] AS varchar(30))

		
		END			'PreMocStatus'



FROM #LABEL

CROSS JOIN #PostMOC 

CROSS JOIN #PreMOC



OPTION (RECOMPILE)

END

-------------------------==========================
--DROP TABLE #LABEL,#PostMOC,#PreMOC














GO