SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [PRO].[CustAccountMerge]
AS

 DECLARE @TimeKey  Int SET @TimeKey=(SELECT TimeKey FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')
 DECLARE @vEffectivefrom  Int SET @vEffectiveFrom=(SELECT TimeKey FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')          
 Declare @vEffectiveto INT Set @vEffectiveto= (select Timekey-1 from [dbo].Automate_Advances where EXT_FLG='Y')

/* ADVCUSTNPA DETAIL */

begin try
	--begin tran

IF OBJECT_ID ('TEMPDB..#AdvCustNPAdetail') IS NOT NULL
DROP TABLE #AdvCustNPAdetail

CREATE TABLE [#AdvCustNPAdetail](
 [ENTITYKEY] BigInt NULL,
 [CustomerEntityId] [int] NOT NULL,
 [Cust_AssetClassAlt_Key] [smallint] NULL,
 [NPADt] [date] NULL,
 [LastInttChargedDt] [date] NULL,
 [DbtDt] [date] NULL,
 [LosDt] [date] NULL,
 [DefaultReason1Alt_Key] [smallint] NULL,
 [DefaultReason2Alt_Key] [smallint] NULL,
 [StaffAccountability] [char](1) NULL,
 [LastIntBooked] [date] NULL,
 [RefCustomerID] [varchar](30) NULL,
 [AuthorisationStatus] [varchar](2) NULL,
 [EffectiveFromTimeKey] [int] NOT NULL,
 [EffectiveToTimeKey] [int] NOT NULL,
 [CreatedBy] [varchar](20) NULL,
 [DateCreated] [date] NULL,
 [ModifiedBy] [varchar](20) NULL,
 [DateModified] [date] NULL,
 [ApprovedBy] [varchar](20) NULL,
 [DateApproved] [date] NULL,
 [D2Ktimestamp] Datetime NULL,
 [MocStatus] [char](1) NULL,
 [MocDate] [date] NULL,
 [MocTypeAlt_Key] [int] NULL,
 [NPA_Reason] [varchar](1000) NULL,
  IsChanged Char(1) NULL
) ON [PRIMARY]




INSERT INTO #AdvCustNPAdetail

(
 CustomerEntityId
,Cust_AssetClassAlt_Key
,NPADt
,LastInttChargedDt
,DbtDt
,LosDt
,DefaultReason1Alt_Key
,DefaultReason2Alt_Key
,StaffAccountability
,LastIntBooked
,RefCustomerID
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,MocStatus
,MocDate
,MocTypeAlt_Key
,NPA_Reason
)

   SELECT 
     CustomerEntityId
     ,A.SysAssetClassAlt_Key Cust_AssetClassAlt_Key
     ,SysNPA_Dt NPADt
     ,NULL LastInttChargedDt
     ,DbtDt DbtDt
     ,LossDt LosDt
     ,NULL DefaultReason1Alt_Key
     ,NULL DefaultReason2Alt_Key
     ,NULL StaffAccountability
     ,NULL LastIntBooked
     ,RefCustomerID RefCustomerID
     ,NULL AuthorisationStatus
     ,A.EffectiveFromTimeKey EffectiveFromTimeKey
     ,49999 EffectiveToTimeKey
     ,NULL CreatedBy
     ,GETDATE() DateCreated
     ,NULL ModifiedBy
     ,NULL DateModified
     ,NULL ApprovedBy
     ,NULL DateApproved
     ,NULL MocStatus
     ,NULL MocDate
     ,NULL MocTypeAlt_Key
     ,A.DegReason AS NPA_Reason
   FROM PRO.CustomerCal A
   INNER JOIN dbo.DimAssetClass B
     ON  (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)AND
     A.SysAssetClassAlt_Key=B.AssetClassAlt_Key
    AND ISNULL(B.AssetClassShortNameEnum,'STD')<>'STD'


----------For New Records
UPDATE A SET A.IsChanged='N'
----Select * 
from #AdvCustNPAdetail A
Where Not Exists(Select 1 from DBO.AdvCustNPADetail B Where B.EffectiveToTimeKey=49999
And B.CustomerEntityId=A.CustomerEntityId) 


/* EXPIRE RECORDS FOR PREV TI,EKEY */
UPDATE O SET 
 O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSERACL'

From dbo.AdvCustNPAdetail AS O
Inner Join  #AdvCustNPAdetail AS T
ON      O.CustomerEntityId=T.CustomerEntityId
    AND O.EFFECTIVETOTimekey=49999
 AND T.EFFECTIVETOTimekey=49999
 and O.EffectiveFromTimeKey<@TimeKey
 Where
		(
			 ISNULL(O.[Cust_AssetClassAlt_Key],0)<> ISNULL(T.[Cust_AssetClassAlt_Key],0)
			 OR  ISNULL(O.[NPADt],'1900-01-01')      <> ISNULL(t.[NPADt],'1900-01-01')
			 OR  ISNULL(O.[LosDt],'1900-01-01')      <> ISNULL(t.[LosDt],'1900-01-01')
			 OR  ISNULL(O.[DbtDt],'1900-01-01')      <> ISNULL(t.[DbtDt],'1900-01-01')
			----- OR  isnull(O.[RefCustomerID],'')		 <> IsnuLL(T.[RefCustomerID],'')
         ) 

/* UPDATE RECORDS FOR CURRENT TIMEKEY */
UPDATE O SET 
 O.[Cust_AssetClassAlt_Key]=T.Cust_AssetClassAlt_Key
 ,O.[NPADt]			= T.[NPADt]
 ,O.[LosDt]			= T.[LosDt]
 ,O.[DbtDt]			= T.[DbtDt]
 ,O.DateModified=CONVERT(DATE,GETDATE(),103)
 ,O.ModifiedBy='SSISUSERACL'

From dbo.AdvCustNPAdetail AS O
Inner Join  #AdvCustNPAdetail AS T
ON      O.CustomerEntityId=T.CustomerEntityId
    AND O.EFFECTIVETOTimekey=49999
 AND T.EFFECTIVETOTimekey=49999
 and O.EffectiveFromTimeKey=@TimeKey

 /* EXPIRE PREVIOUS NPA AND STD IN CURRENT */
 UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=Convert(date,getdate(),103),
 ModifiedBy='SSISUSERACL' 
FROM dbo.AdvCustNPAdetail AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM #AdvCustNPAdetail BB
					WHERE AA.CustomerEntityId=BB.CustomerEntityId
					AND BB.EffectiveToTimeKey =49999
			   )



----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from #AdvCustNPAdetail A
INNER JOIN DBO.AdvCustNPADetail B 
ON B.CustomerEntityId=A.CustomerEntityId            
Where B.EffectiveToTimeKey= @vEffectiveto
		AND b.EffectiveFromTimeKey<@TimeKey
AND B.ModifiedBy='SSISUSERACL'


/*  New Customers EntityKey ID Update  */
DECLARE @EntityKey BIGINT=0 
SELECT @EntityKey=MAX(EntityKey) FROM  [dbo].[AdvCustNPADetail] 
IF @EntityKey IS NULL  
BEGIN
SET @EntityKey=0
END
 
UPDATE TEMP 
SET TEMP.EntityKey=ACCT.EntityKey
 FROM #AdvCustNPAdetail TEMP
INNER JOIN (SELECT CustomerEntityId,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
			FROM #AdvCustNPAdetail
			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON TEMP.CustomerEntityId=ACCT.CustomerEntityId
Where Temp.IsChanged in ('N','C')



INSERT INTO DBO.AdvCustNPADetail
  (
     [ENTITYKEY]
      ,[CustomerEntityId]
      ,[Cust_AssetClassAlt_Key]
      ,[NPADt]
      ,[LastInttChargedDt]
      ,[DbtDt]
      ,[LosDt]
      ,[DefaultReason1Alt_Key]
      ,[DefaultReason2Alt_Key]
      ,[StaffAccountability]
      ,[LastIntBooked]
      ,[RefCustomerID]
      ,[AuthorisationStatus]
      ,[EffectiveFromTimeKey]
      ,[EffectiveToTimeKey]
      ,[CreatedBy]
      ,[DateCreated]
      ,[ModifiedBy]
      ,[DateModified]
      ,[ApprovedBy]
      ,[DateApproved]
      ,[D2Ktimestamp]
      ,[MocStatus]
      ,[MocDate]
      ,[MocTypeAlt_Key]
      ,[NPA_Reason]
						)

SELECT 

		ENTITYKEY
      ,CustomerEntityId
      ,Cust_AssetClassAlt_Key
      ,NPADt
      ,LastInttChargedDt
      ,DbtDt
      ,LosDt
      ,DefaultReason1Alt_Key
      ,DefaultReason2Alt_Key
      ,StaffAccountability
      ,LastIntBooked
      ,RefCustomerID
      ,AuthorisationStatus
      ,EffectiveFromTimeKey
      ,EffectiveToTimeKey
      ,CreatedBy
      ,DateCreated
      ,ModifiedBy
      ,DateModified
      ,ApprovedBy
      ,DateApproved
      ,Getdate() D2Ktimestamp
      ,MocStatus
      ,MocDate
      ,MocTypeAlt_Key
      ,NPA_Reason
	   FROM #AdvCustNPAdetail T Where ISNULL(T.IsChanged,'U') IN ('N','C')
  ------------------End



/*        AdvAcFinancialDetail  Start         */
--Commented on 18062024 by Jaydev/Sudesh as this is not reqd-------------
 
--IF OBJECT_ID ('TEMPDB..#AdvAcFinancialDetail') IS NOT NULL
--DROP TABLE #AdvAcFinancialDetail

--CREATE TABLE #AdvAcFinancialDetail
--(
--[ENTITYKEY] [bigint]  NULL,
--	[AccountEntityId] [int] NOT NULL,
--	[Ac_LastReviewDueDt] [date] NULL,
--	[Ac_ReviewTypeAlt_key] [smallint] NULL,
--	[Ac_ReviewDt] [date] NULL,
--	[Ac_ReviewAuthAlt_Key] [smallint] NULL,
--	[Ac_NextReviewDueDt] [date] NULL,
--	[DrawingPower] [decimal](14, 0) NULL,
--	[InttRate] [decimal](4, 2) NULL,
--	[NpaDt] [date] NULL,
--	[BookDebts] [decimal](14, 0) NULL,
--	[UnDrawnAmt] [decimal](14, 0) NULL,
--	[UnAdjSubSidy] [decimal](14, 0) NULL,
--	[LastInttRealiseDt] [date] NULL,
--	[MocStatus] [varchar](10) NULL,
--	[MOCReason] [smallint] NULL,
--	[LimitDisbursed] [decimal](14, 0) NULL,
--	[RefCustomerId] [varchar](20) NULL,
--	[RefSystemAcId] [varchar](30) NULL,
--	[AuthorisationStatus] [char](2) NULL,
--	[EffectiveFromTimeKey] [int] NOT NULL,
--	[EffectiveToTimeKey] [int] NOT NULL,
--	[CreatedBy] [varchar](20) NULL,
--	[DateCreated] [smalldatetime] NULL,
--	[ModifiedBy] [varchar](20) NULL,
--	[DateModified] [smalldatetime] NULL,
--	[ApprovedBy] [varchar](20) NULL,
--	[DateApproved] [smalldatetime] NULL,
--	[D2Ktimestamp] [datetime]  NULL,
--	[MocDate] [smalldatetime] NULL,
--	[MocTypeAlt_Key] [int] NULL,
--	[CropDuration] [smallint] NULL,
--	[Ac_ReviewAuthLevelAlt_Key] [smallint] NULL,
--	[AccountBlkCode2][varchar](20) NULL,
--	ISChanged Char(1) NULL	
--)



--INsert into #AdvAcFinancialDetail
--(
--ENTITYKEY
--,AccountEntityId
--,Ac_LastReviewDueDt
--,Ac_ReviewTypeAlt_key
--,Ac_ReviewDt
--,Ac_ReviewAuthAlt_Key
--,Ac_NextReviewDueDt
--,DrawingPower
--,InttRate
--,NpaDt
--,BookDebts
--,UnDrawnAmt
--,UnAdjSubSidy
--,LastInttRealiseDt
--,MocStatus
--,MOCReason
--,LimitDisbursed
--,RefCustomerId
--,RefSystemAcId
--,AuthorisationStatus
--,EffectiveFromTimeKey
--,EffectiveToTimeKey
--,CreatedBy
--,DateCreated
--,ModifiedBy
--,DateModified
--,ApprovedBy
--,DateApproved
--,D2Ktimestamp
--,MocDate
--,MocTypeAlt_Key
--,CropDuration
--,Ac_ReviewAuthLevelAlt_Key
--,AccountBlkCode2
--)

--Select 

--NULL ENTITYKEY
--,B.AccountEntityId
--,B.Ac_LastReviewDueDt
--,B.Ac_ReviewTypeAlt_key
--,B.Ac_ReviewDt
--,B.Ac_ReviewAuthAlt_Key
--,B.Ac_NextReviewDueDt
--,B.DrawingPower
--,B.InttRate
--,A.FinalNpaDt NpaDt
--,B.BookDebts
--,B.UnDrawnAmt
--,B.UnAdjSubSidy
--,B.LastInttRealiseDt
--,B.MocStatus
--,B.MOCReason
--,B.LimitDisbursed
--,B.RefCustomerId
--,B.RefSystemAcId
--,B.AuthorisationStatus
--,@TimeKey EffectiveFromTimeKey
--,49999 EffectiveToTimeKey
--,B.CreatedBy
--,B.DateCreated
--,B.ModifiedBy
--,B.DateModified
--,B.ApprovedBy
--,B.DateApproved
--,NULL D2Ktimestamp
--,B.MocDate
--,B.MocTypeAlt_Key
--,B.CropDuration
--,B.Ac_ReviewAuthLevelAlt_Key
--,B.AccountBlkCode2
--From Pro.AccountCal A
--Inner Join dbo.AdvAcFinancialDetail B 
--ON A.AccountEntityId=B.AccountEntityID 
--And B.EffectiveToTimeKey=49999
--And  ISNULL(B.NpaDt,'1900-01-01')   <> ISNULL(A.FinalNpaDt,'1900-01-01')     

-------------------------------------------------

--UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
-- O.DateModified=CONVERT(DATE,GETDATE(),103),
-- O.ModifiedBy='SSISUSERACL'
--From dbo.AdvAcFinancialDetail  AS O
--Inner Join #AdvAcFinancialDetail AS T
--ON  O.AccountEntityID=T.AccountEntityID
--AND O.EffectiveToTimeKey=49999
--AND O.EffectiveFromTimeKey <@TimeKey

-- Where 
--(  
-- ISNULL(O.NpaDt,'1900-01-01')   <> ISNULL(T.NpaDt,'1900-01-01')     
--)


-------------------------------------------------

--UPDATE O SET O.NpaDt=T.NpaDt,
-- O.DateModified=CONVERT(DATE,GETDATE(),103),
-- O.ModifiedBy='SSISUSERACL'

--From dbo.AdvAcFinancialDetail  AS O
--Inner Join #AdvAcFinancialDetail AS T
--ON  O.AccountEntityID=T.AccountEntityID
--AND O.EffectiveToTimeKey=49999
--AND O.EffectiveFromTimeKey =@TimeKey
-- Where 
--(  
-- ISNULL(O.NpaDt,'1900-01-01')   <> ISNULL(T.NpaDt,'1900-01-01')     
--)

--update t set t.IsChanged='D'
--From dbo.AdvAcFinancialDetail  AS O
--Inner Join #AdvAcFinancialDetail AS T
--ON  O.AccountEntityID=T.AccountEntityID
--AND O.EffectiveToTimeKey=49999
--AND O.EffectiveFromTimeKey =@TimeKey

--/***************************************************************************************************************/


----  ----------For Changes Records
----UPDATE A SET A.IsChanged='C'
--------Select * 
----from #AdvAcFinancialDetail A
----INNER JOIN DBO.AdvAcFinancialDetail B 
----ON B.AccountEntityId=A.AccountEntityId   
----Where B.EffectiveToTimeKey= @vEffectiveto
----And B.ModifiedBy='SSISUSERACL'




--/*  New Customers EntityKey ID Update  */

--sET @EntityKey =0 
--SELECT @EntityKey=MAX(EntityKey) FROM  [dbo].[AdvAcFinancialDetail] 
--IF @EntityKey IS NULL  
--BEGIN
--SET @EntityKey=0
--END
 
--UPDATE TEMP 
--SET TEMP.EntityKey=ACCT.EntityKey
-- FROM #AdvAcFinancialDetail TEMP
--INNER JOIN (SELECT AccountEntityId,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
--			FROM #AdvAcFinancialDetail
--			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON TEMP.AccountEntityId=ACCT.AccountEntityId
-----Where Temp.IsChanged in ('N','C')



--------------------------------------------------------------------


--INSERT INTO DBO.AdvAcFinancialDetail
--(	[ENTITYKEY]
--      ,[AccountEntityId]
--      ,[Ac_LastReviewDueDt]
--      ,[Ac_ReviewTypeAlt_key]
--      ,[Ac_ReviewDt]
--      ,[Ac_ReviewAuthAlt_Key]
--      ,[Ac_NextReviewDueDt]
--      ,[DrawingPower]
--      ,[InttRate]
--      ,[NpaDt]
--      ,[BookDebts]
--      ,[UnDrawnAmt]
--      ,[UnAdjSubSidy]
--      ,[LastInttRealiseDt]
--      ,[MocStatus]
--      ,[MOCReason]
--      ,[LimitDisbursed]
--      ,[RefCustomerId]
--      ,[RefSystemAcId]
--      ,[AuthorisationStatus]
--      ,[EffectiveFromTimeKey]
--      ,[EffectiveToTimeKey]
--      ,[CreatedBy]
--      ,[DateCreated]
--      ,[ModifiedBy]
--      ,[DateModified]
--      ,[ApprovedBy]
--      ,[DateApproved]
--      ,[D2Ktimestamp]
--      ,[MocDate]
--      ,[MocTypeAlt_Key]
--      ,[CropDuration]
--      ,[Ac_ReviewAuthLevelAlt_Key]
--	  ,AccountBlkCode2
	  
--           )
--SELECT
	
--	  ENTITYKEY
--      ,AccountEntityId
--      ,Ac_LastReviewDueDt
--      ,Ac_ReviewTypeAlt_key
--      ,Ac_ReviewDt
--      ,Ac_ReviewAuthAlt_Key
--      ,Ac_NextReviewDueDt
--      ,DrawingPower
--      ,InttRate
--      ,NpaDt
--      ,BookDebts
--      ,UnDrawnAmt
--      ,UnAdjSubSidy
--      ,LastInttRealiseDt
--      ,MocStatus
--      ,MOCReason
--      ,LimitDisbursed
--      ,RefCustomerId
--      ,RefSystemAcId
--      ,AuthorisationStatus
--      ,EffectiveFromTimeKey
--      ,EffectiveToTimeKey
--      ,CreatedBy
--      ,DateCreated
--      ,ModifiedBy
--      ,DateModified
--      ,ApprovedBy
--      ,DateApproved
--      ,getdate() D2Ktimestamp
--      ,MocDate
--      ,MocTypeAlt_Key
--      ,CropDuration
--      ,Ac_ReviewAuthLevelAlt_Key
--	  ,AccountBlkCode2
	  
--	FROM #AdvAcFinancialDetail T Where ISNULL(T.IsChanged,'U')<>'D'--IN ('N','C')

	/*        AdvAcFinancialDetail  END         */


-------
-----------------------------------------------------------------------------------------------------------------------------------------
/*        AdvAcBalanceDetail  Start         */

IF OBJECT_ID ('TEMPDB..#AdvAcBalanceDetail') IS NOT NULL
DROP TABLE #AdvAcBalanceDetail

CREATE TABLE [#AdvAcBalanceDetail](
[EntityKey] [bigint]  NULL,
	[AccountEntityId] [int] NOT NULL,
	[AssetClassAlt_Key] [smallint] NULL,
	[BalanceInCurrency] [decimal](16, 2) NULL,
	[Balance] [decimal](16, 2) NULL,
	[SignBalance] [decimal](16, 2) NULL,
	[LastCrDt] [date] NULL,
	[OverDue] [decimal](16, 2) NULL,
	[TotalProv] [decimal](16, 2) NULL,
	[RefCustomerId] [varchar](20) NULL,
	[RefSystemAcId] [varchar](30) NULL,
	[AuthorisationStatus] [char](2) NULL,
	[EffectiveFromTimeKey] [int] NOT NULL,
	[EffectiveToTimeKey] [int] NOT NULL,
	[OverDueSinceDt] [date] NULL,
	[MocStatus] [char](1) NULL,
	[MocDate] [smalldatetime] NULL,
	[MocTypeAlt_Key] [int] NULL,
	[Old_OverDueSinceDt] [date] NULL,
	[Old_OverDue] [decimal](16, 2) NULL,
	[ORG_TotalProv] [decimal](16, 2) NULL,
	[IntReverseAmt] [decimal](16, 2) NULL,
	[UnAppliedIntAmount] [decimal](18, 2) NULL,
	[PS_Balance] [decimal](16, 2) NULL,
	[NPS_Balance] [decimal](16, 2) NULL,
	[DateCreated] [date] NULL,
	[ModifiedBy] [varchar](50) NULL,
	[DateModified] [date] NULL,
	[ApprovedBy] [varchar](50) NULL,
	[DateApproved] [date] NULL,
	[CreatedBy] [varchar](50) NULL,
	[UpgradeDate] [date] NULL,
	[OverduePrincipal] [decimal](18, 2) NULL,
	[NotionalInttAmt] [decimal](16, 2) NULL,
	[PrincipalBalance] [decimal](18, 2) NULL,
	[Overdueinterest] [decimal](16, 2) NULL,
	[AdvanceRecovery] [decimal](16, 2) NULL,
	[PS_NPS_FLAG] [varchar](3) NULL,
	[DFVAmt] [decimal](18, 2) NULL,
	[InterestReceivable] [decimal](18, 2) NULL,
	[OverduePrincipalDt] [date] NULL,
	[OverdueIntDt] [date] NULL,
	[OverOtherdue] [decimal](18, 2) NULL,
	[OverdueOtherDt] [date] NULL,
	IsChanged Char(1) NULL,
	SourceAssetClass  Varchar(100) NULL,
	SourceNpaDate   smalldatetime,
	dpd_bank		int
	)


Insert into #AdvAcBalanceDetail
(
EntityKey
,AccountEntityId
,AssetClassAlt_Key
,BalanceInCurrency
,Balance
,SignBalance
,LastCrDt
,OverDue
,TotalProv
,RefCustomerId
,RefSystemAcId
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,OverDueSinceDt
,MocStatus
,MocDate
,MocTypeAlt_Key
,Old_OverDueSinceDt
,Old_OverDue
,ORG_TotalProv
,IntReverseAmt
,UnAppliedIntAmount
,PS_Balance
,NPS_Balance
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,CreatedBy
,UpgradeDate
,OverduePrincipal
,NotionalInttAmt
,PrincipalBalance
,Overdueinterest
,AdvanceRecovery
,PS_NPS_FLAG
,DFVAmt
,InterestReceivable
,OverduePrincipalDt
,OverdueIntDt
,OverOtherdue
,OverdueOtherDt
,SourceAssetClass
,SourceNpaDate
,dpd_bank
)

Select 

NULL EntityKey
,A.AccountEntityId
,A.FinalAssetClassAlt_Key AssetClassAlt_Key
,B.BalanceInCurrency
,A.Balance Balance
,b.SignBalance
,B.LastCrDt
,B.OverDue
,A.TotalProvision TotalProv
,B.RefCustomerId
,B.RefSystemAcId
,B.AuthorisationStatus
,@TimeKey EffectiveFromTimeKey
,49999 EffectiveToTimeKey
,B.OverDueSinceDt
,B.MocStatus
,B.MocDate
,B.MocTypeAlt_Key
,B.Old_OverDueSinceDt
,B.Old_OverDue
,B.ORG_TotalProv
,B.IntReverseAmt
,B.UnAppliedIntAmount
,B.PS_Balance
,B.NPS_Balance
,B.DateCreated
,B.ModifiedBy
,B.DateModified
,B.ApprovedBy
,B.DateApproved
,B.CreatedBy
,B.UpgradeDate
,b.OverduePrincipal
,B.NotionalInttAmt
,A.PrincOutStd PrincipalBalance
,B.Overdueinterest
,B.AdvanceRecovery
,B.PS_NPS_FLAG
,B.DFVAmt
,B.InterestReceivable
,B.OverduePrincipalDt
,B.OverdueIntDt
,B.OverOtherdue
,B.OverdueOtherDt
,B.SourceAssetClass
,B.SourceNpaDate
,b.DPD_Bank
From Pro.ACCOUNTCAL A
Inner JOIN  Dbo.AdvAcBalanceDetail B 
ON A.AccountEntityID=B.AccountEntityId And B.EffectiveToTimeKey=49999
 Where 
(  
	   ISNULL(B.ASSETCLASSALT_KEY,0)    <> ISNULL(A.FINALASSETCLASSALT_KEY,0)    
	OR ISNULL(B.BALANCE,0)				<> ISNULL(A.BALANCE,0)      
	OR ISNULL(B.TOTALPROV,0)			<> ISNULL(A.TOTALPROVISION,0)     
	OR ISNULL(B.PrincipalBalance,0)     <> ISNULL(A.PrincOutStd,0) 
)


-----------------------------------------------------------------------------------------------------------------------------------------


UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSERACL'

From DBO.ADVACBALANCEDETAIL  AS O
	INNER JOIN #AdvAcBalanceDetail AS T
ON  O.AccountEntityID=T.AccountEntityID
	AND O.EffectiveToTimeKey=49999
	AND O.EffectiveFromTimeKey <@TimeKey

 Where 
(  
	ISNULL(O.ASSETCLASSALT_KEY,0)    <> ISNULL(T.ASSETCLASSALT_KEY,0)    
	OR ISNULL(O.BALANCE,0)      <> ISNULL(T.BALANCE,0)      
	OR ISNULL(O.TOTALPROV,0)     <> ISNULL(T.TOTALPROV,0)     
	OR ISNULL(O.PrincipalBalance,0)    <> ISNULL(T.PrincipalBalance,0) 
)

-----------------For Same TimeKey And EffectiveFromTimeKey

UPDATE O SET O.ASSETCLASSALT_KEY=T.ASSETCLASSALT_KEY,
			O.BALANCE=T.BALANCE,
			O.TOTALPROV=T.TOTALPROV,
			O.PrincipalBalance=T.PrincipalBalance,
			 O.DateModified=CONVERT(DATE,GETDATE(),103),
			 O.ModifiedBy='SSISUSERACL'
From DBO.ADVACBALANCEDETAIL  AS O
	Inner Join #AdvAcBalanceDetail AS T
ON  O.AccountEntityID=T.AccountEntityID
	AND O.EffectiveToTimeKey=49999
	AND O.EffectiveFromTimeKey = @TimeKey

 Where 
	(  
		 ISNULL(O.ASSETCLASSALT_KEY,0)    <> ISNULL(T.ASSETCLASSALT_KEY,0)    
		OR ISNULL(O.BALANCE,0)      <> ISNULL(T.BALANCE,0)      
		OR ISNULL(O.TOTALPROV,0)     <> ISNULL(T.TOTALPROV,0)     
		OR ISNULL(O.PrincipalBalance,0)    <> ISNULL(T.PrincipalBalance,0) 
	)

UPDATE T SET t.IsChanged='D'
From DBO.ADVACBALANCEDETAIL  AS O
	Inner Join #AdvAcBalanceDetail AS T
ON  O.AccountEntityID=T.AccountEntityID
	AND O.EffectiveToTimeKey=49999
	AND O.EffectiveFromTimeKey = @TimeKey


----------For Changes Records
--UPDATE A SET A.IsChanged='C'
--from #AdvAcBalanceDetail A
--INNER JOIN DBO.AdvAcBalanceDetail B 
--ON B.AccountEntityId=A.AccountEntityId            
--Where B.EffectiveToTimeKey= @vEffectiveto
--And B.ModifiedBy='SSISUSERACL'


/*  New Customers EntityKey ID Update  */
SET @EntityKey =0 
SELECT @EntityKey=MAX(EntityKey) FROM  IBL_ENPA_DB_V2.[dbo].[AdvAcBalanceDetail] 
IF @EntityKey IS NULL  
BEGIN
SET @EntityKey=0
END
 
UPDATE TEMP 
SET TEMP.EntityKey=ACCT.EntityKey
 FROM #AdvAcBalanceDetail TEMP
INNER JOIN (SELECT AccountEntityId,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
			FROM #AdvAcBalanceDetail
			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON TEMP.AccountEntityId=ACCT.AccountEntityId
--Where Temp.IsChanged in ('N','C')


/***************************************************************************************************************/

INSERT INTO DBO.AdvAcBalanceDetail
		(	EntityKey
			,AccountEntityId
			,AssetClassAlt_Key
			,BalanceInCurrency
			,Balance
			,SignBalance
			,LastCrDt
			,OverDue
			,TotalProv
			,RefCustomerId
			,RefSystemAcId
			,AuthorisationStatus
			,EffectiveFromTimeKey
			,EffectiveToTimeKey
			,OverDueSinceDt
			,MocStatus
			,MocDate
			,MocTypeAlt_Key
			,Old_OverDueSinceDt
			,Old_OverDue
			,ORG_TotalProv
			,IntReverseAmt
			,UnAppliedIntAmount
			,PS_Balance
			,NPS_Balance
			,DateCreated
			,ModifiedBy
			,DateModified
			,ApprovedBy
			,DateApproved
			,CreatedBy
			,UpgradeDate
			,OverduePrincipal
			,NotionalInttAmt
			,PrincipalBalance
			,Overdueinterest
			,AdvanceRecovery
			,PS_NPS_FLAG
			,DFVAmt
			,InterestReceivable
			,OverduePrincipalDt
			,OverdueIntDt
			,OverOtherdue
			,OverdueOtherDt
			,SourceAssetClass
			,SourceNpaDate
			,DPD_Bank
		   )
	SELECT
		    EntityKey
			,AccountEntityId
			,AssetClassAlt_Key
			,BalanceInCurrency
			,Balance
			,SignBalance
			,LastCrDt
			,OverDue
			,TotalProv
			,RefCustomerId
			,RefSystemAcId
			,AuthorisationStatus
			,EffectiveFromTimeKey
			,EffectiveToTimeKey
			,OverDueSinceDt
			,MocStatus
			,MocDate
			,MocTypeAlt_Key
			,Old_OverDueSinceDt
			,Old_OverDue
			,ORG_TotalProv
			,IntReverseAmt
			,UnAppliedIntAmount
			,PS_Balance
			,NPS_Balance
			,DateCreated
			,ModifiedBy
			,DateModified
			,ApprovedBy
			,DateApproved
			,CreatedBy
			,UpgradeDate
			,OverduePrincipal
			,NotionalInttAmt
			,PrincipalBalance
			,Overdueinterest
			,AdvanceRecovery
			,PS_NPS_FLAG
			,DFVAmt
			,InterestReceivable
			,OverduePrincipalDt
			,OverdueIntDt
			,OverOtherdue
			,OverdueOtherDt
			,SourceAssetClass
			,SourceNpaDate
			,DPD_Bank
	   FROM #AdvAcBalanceDetail T  Where ISNULL(T.IsChanged,'U')<>'D'-- IN ('N','C')


--commit tran
end try
begin catch
	select ERROR_MESSAGE()
	--rollback tran
end catch
/*        AdvAcBalanceDetail  END         */



GO