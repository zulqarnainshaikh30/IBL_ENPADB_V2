SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [PRO].[CustAccountMerge_MOC]
	@TIMEKEY INT
AS

------DECLARE @TIMEKEY INT=26267
---------- DECLARE @TimeKey  Int SET @TimeKey=(SELECT TimeKey FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')
 DECLARE @vEffectivefrom  Int =@TimeKey-- SET @vEffectiveFrom=(SELECT TimeKey FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')          
 Declare @vEffectiveto INT=@TimeKey-1--- Set @vEffectiveto= (select Timekey-1 from [dbo].Automate_Advances where EXT_FLG='Y')

/* ADVCUSTNPA DETAIL */

begin try
	begin tran

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
 IsChanged Char(1) NULL,
 IsChanged2 Char(1) NULL
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


	DROP TABLE IF EXISTS #NPA_DATA
		SELECT A.*, cast(0 as int) NewEntityKey, 'N' IsChanged INTO #NPA_DATA FROM AdvCustNPADetail A
			INNER JOIN PRO.CustomerCal B
				ON A.CustomerEntityId =B.CustomerEntityId
		WHERE A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
			



	----------For New Records
	UPDATE A SET A.IsChanged='N'
	----Select * 
	from #AdvCustNPAdetail A
	Where Not Exists(Select 1 from #NPA_DATA B Where b.EffectiveFromTimeKey=@TimeKey and B.EffectiveToTimeKey=@TimeKey 
	And B.CustomerEntityId=A.CustomerEntityId) 


/* EXPIRE RECORDS FOR PREV TI,EKEY */
	UPDATE O SET 
	 O.EffectiveToTimeKey=@vEffectiveto,
	 O.DateModified=CONVERT(DATE,GETDATE(),103),
	 O.ModifiedBy='SSISUSERACL-MOC'

	From dbo.AdvCustNPAdetail AS O
	Inner Join  #AdvCustNPAdetail AS T
	ON      O.CustomerEntityId=T.CustomerEntityId
		AND (O.EFFECTIVETOTimekey<=@TimeKey AND O.EFFECTIVETOTimekey>=@TimeKey)
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
		 ,O.ModifiedBy='SSISUSERACL-MOC'
		 ,O.EffectiveToTimeKey =@TimeKey
	From dbo.AdvCustNPAdetail AS O
	Inner Join  #AdvCustNPAdetail AS T
	ON  O.CustomerEntityId=T.CustomerEntityId
		and O.EffectiveFromTimeKey=@TimeKey AND O.EffectiveToTimeKey >=@TimeKey

	 /* EXPIRE PREVIOUS NPA AND STD IN CURRENT */
	UPDATE AA
	SET 
		 EffectiveToTimeKey = @vEffectiveto,
		 DateModified=Convert(date,getdate(),103),
		 ModifiedBy='SSISUSERACL-MOC' 
	FROM dbo.AdvCustNPAdetail AA
	WHERE AA.EffectiveToTimeKey <=@TimeKey and aa.EffectiveToTimeKey>=@TimeKey
		AND NOT EXISTS (SELECT 1 FROM #AdvCustNPAdetail BB
							WHERE AA.CustomerEntityId=BB.CustomerEntityId
						
						)




----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from #AdvCustNPAdetail A
INNER JOIN DBO.AdvCustNPADetail B 
ON B.CustomerEntityId=A.CustomerEntityId            
Where B.EffectiveToTimeKey= @vEffectiveto 
		AND b.EffectiveFromTimeKey<@TimeKey
AND B.ModifiedBy='SSISUSERACL-MOC'

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
			FROM #AdvCustNPAdetail where IsChanged in ('N','C')
			and EntityKey=0 OR EntityKey IS NULL)ACCT ON TEMP.CustomerEntityId=ACCT.CustomerEntityId
Where Temp.IsChanged in ('N','C')


UPDATE A
SET A.IsChanged=NULL 
FROM #AdvCustNPAdetail A
	INNER JOIN AdvCustNPADetail B
		ON A.CustomerEntityId =B.CustomerEntityId
		AND B.EffectiveFromTimeKey=@TIMEKEY AND B.EffectiveToTimeKey=@TIMEKEY

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
      ,@TimeKey EffectiveFromTimeKey
      ,@TimeKey EffectiveToTimeKey
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


 

	/*  New Customers EntityKey ID Update  */
	
		SELECT @EntityKey=MAX(EntityKey) FROM  [dbo].[AdvCustNPADetail] 
		IF @EntityKey IS NULL  
		BEGIN
		SET @EntityKey=0
		END
 
		UPDATE TEMP 
		SET TEMP.NewEntityKey=ACCT.NewEntityKey
		 FROM #NPA_DATA TEMP
		INNER JOIN (SELECT CustomerEntityId,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) NewEntityKey
					FROM #NPA_DATA
					WHERE EntityKey=0 OR EntityKey IS NULL
						 and EffectiveToTimeKey>@TimeKey
					)ACCT ON TEMP.CustomerEntityId=ACCT.CustomerEntityId
			where EffectiveToTimeKey>@TimeKey

	update t	
		set t.IsChanged ='Y'
	FROM #NPA_DATA T 
		Where T.EffectiveToTimeKey>@TimeKey
			and CustomerEntityId in (
										SELECT CustomerEntityId FROM  #AdvCustNPAdetail TT
										WHERE TT.IsChanged='C'
									)	
	
	/* INSERT DATA FOR NEXT TIME KE IF EXISTING RECORDS ARE AVAILABLE FOR NEXT TIMEKEY */
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
		  T.NewEntityKey	ENTITYKEY
		  ,T.CustomerEntityId
		  ,T.Cust_AssetClassAlt_Key
		  ,T.NPADt
		  ,T.LastInttChargedDt
		  ,T.DbtDt
		  ,T.LosDt
		  ,T.DefaultReason1Alt_Key
		  ,T.DefaultReason2Alt_Key
		  ,T.StaffAccountability
		  ,T.LastIntBooked
		  ,T.RefCustomerID
		  ,T.AuthorisationStatus
		  ,@TimeKey+1 EffectiveFromTimeKey
		  ,T.EffectiveToTimeKey
		  ,T.CreatedBy
		  ,T.DateCreated
		  ,T.ModifiedBy
		  ,T.DateModified
		  ,T.ApprovedBy
		  ,T.DateApproved
		  ,Getdate() D2Ktimestamp
		  ,T.MocStatus
		  ,T.MocDate
		  ,T.MocTypeAlt_Key
		  ,T.NPA_Reason
		FROM #NPA_DATA T 
		Where T.EffectiveToTimeKey>@TimeKey
			and IsChanged='Y'
			--and CustomerEntityId in (
			--							SELECT CustomerEntityId FROM  #AdvCustNPAdetail TT
			--							WHERE TT.IsChanged='C'
			--						)
	/* PRE MOC DATA INSERT */
	
	INSERT INTO PreMoc.AdvCustNPADetail
	  (
		 
		  [CustomerEntityId]
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
		  T.CustomerEntityId
		  ,T.Cust_AssetClassAlt_Key
		  ,T.NPADt
		  ,T.LastInttChargedDt
		  ,T.DbtDt
		  ,T.LosDt
		  ,T.DefaultReason1Alt_Key
		  ,T.DefaultReason2Alt_Key
		  ,T.StaffAccountability
		  ,T.LastIntBooked
		  ,T.RefCustomerID
		  ,T.AuthorisationStatus
		  ,@TimeKey EffectiveFromTimeKey
		  ,@TimeKey EffectiveToTimeKey
		  ,T.CreatedBy
		  ,T.DateCreated
		  ,T.ModifiedBy
		  ,T.DateModified
		  ,T.ApprovedBy
		  ,T.DateApproved
		  ,Getdate() D2Ktimestamp
		  ,T.MocStatus
		  ,T.MocDate
		  ,T.MocTypeAlt_Key
		  ,T.NPA_Reason
	FROM #NPA_DATA T 
		LEFT JOIN PREMOC.ADVCUSTNPADETAIL B
			ON B.EffectiveFromTimeKey=@TimeKey AND  B.EffectiveToTimeKey=@TimeKey
			AND T.CustomerEntityId=B.CustomerEntityId
		WHERE B.CustomerEntityId IS NULL
  ------------------End



/*        AdvAcFinancialDetail  Start         */

 
IF OBJECT_ID ('TEMPDB..#AdvAcFinancialDetail') IS NOT NULL
DROP TABLE #AdvAcFinancialDetail

CREATE TABLE #AdvAcFinancialDetail
(
[ENTITYKEY] [bigint]  NULL,
	[AccountEntityId] [int] NOT NULL,
	[Ac_LastReviewDueDt] [date] NULL,
	[Ac_ReviewTypeAlt_key] [smallint] NULL,
	[Ac_ReviewDt] [date] NULL,
	[Ac_ReviewAuthAlt_Key] [smallint] NULL,
	[Ac_NextReviewDueDt] [date] NULL,
	[DrawingPower] [decimal](14, 0) NULL,
	[InttRate] [decimal](4, 2) NULL,
	[NpaDt] [date] NULL,
	[BookDebts] [decimal](14, 0) NULL,
	[UnDrawnAmt] [decimal](14, 0) NULL,
	[UnAdjSubSidy] [decimal](14, 0) NULL,
	[LastInttRealiseDt] [date] NULL,
	[MocStatus] [varchar](10) NULL,
	[MOCReason] [smallint] NULL,
	[LimitDisbursed] [decimal](14, 0) NULL,
	[RefCustomerId] [varchar](20) NULL,
	[RefSystemAcId] [varchar](30) NULL,
	[AuthorisationStatus] [char](2) NULL,
	[EffectiveFromTimeKey] [int] NOT NULL,
	[EffectiveToTimeKey] [int] NOT NULL,
	[CreatedBy] [varchar](20) NULL,
	[DateCreated] [smalldatetime] NULL,
	[ModifiedBy] [varchar](20) NULL,
	[DateModified] [smalldatetime] NULL,
	[ApprovedBy] [varchar](20) NULL,
	[DateApproved] [smalldatetime] NULL,
	[D2Ktimestamp] [datetime]  NULL,
	[MocDate] [smalldatetime] NULL,
	[MocTypeAlt_Key] [int] NULL,
	[CropDuration] [smallint] NULL,
	[Ac_ReviewAuthLevelAlt_Key] [smallint] NULL,
	ISChanged Char(1) NULL
	,AccountBlkCode2 VARCHAR(20)
	,NpaDt_Org date
)



INsert into #AdvAcFinancialDetail
(
ENTITYKEY
,AccountEntityId
,Ac_LastReviewDueDt
,Ac_ReviewTypeAlt_key
,Ac_ReviewDt
,Ac_ReviewAuthAlt_Key
,Ac_NextReviewDueDt
,DrawingPower
,InttRate
,NpaDt
,BookDebts
,UnDrawnAmt
,UnAdjSubSidy
,LastInttRealiseDt
,MocStatus
,MOCReason
,LimitDisbursed
,RefCustomerId
,RefSystemAcId
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,D2Ktimestamp
,MocDate
,MocTypeAlt_Key
,CropDuration
,Ac_ReviewAuthLevelAlt_Key
,NpaDt_Org
)

Select 

NULL ENTITYKEY
,B.AccountEntityId
,B.Ac_LastReviewDueDt
,B.Ac_ReviewTypeAlt_key
,B.Ac_ReviewDt
,B.Ac_ReviewAuthAlt_Key
,B.Ac_NextReviewDueDt
,B.DrawingPower
,B.InttRate
,A.FinalNpaDt NpaDt
,B.BookDebts
,B.UnDrawnAmt
,B.UnAdjSubSidy
,B.LastInttRealiseDt
,B.MocStatus
,B.MOCReason
,B.LimitDisbursed
,B.RefCustomerId
,B.RefSystemAcId
,B.AuthorisationStatus
,b.EffectiveFromTimeKey
,b.EffectiveToTimeKey
,B.CreatedBy
,B.DateCreated
,B.ModifiedBy
,B.DateModified
,B.ApprovedBy
,B.DateApproved
,NULL D2Ktimestamp
,B.MocDate
,B.MocTypeAlt_Key
,B.CropDuration
,B.Ac_ReviewAuthLevelAlt_Key
,B.NpaDt NpaDt_Org
From Pro.AccountCal A
	Inner Join dbo.AdvAcFinancialDetail B ON A.AccountEntityId=B.AccountEntityID 
	And  b.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
	And  ISNULL(B.NpaDt,'1900-01-01')   <> ISNULL(A.FinalNpaDt,'1900-01-01')     

-----------------------------------------------

UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSERACL-MOC'
From dbo.AdvAcFinancialDetail  AS O
Inner Join #AdvAcFinancialDetail AS T
ON  O.AccountEntityID=T.AccountEntityID
AND O.EffectiveFromTimeKey<=@TimeKey AND O.EffectiveToTimeKey>=@TimeKey 
AND O.EffectiveFromTimeKey <@TimeKey

 Where 
(  
 ISNULL(O.NpaDt,'1900-01-01')   <> ISNULL(T.NpaDt,'1900-01-01')     
)


-----------------------------------------------

UPDATE O SET O.NpaDt=T.NpaDt,
	  O.DateModified=CONVERT(DATE,GETDATE(),103),
	  O.ModifiedBy='SSISUSERACL-MOC'
	 ,O.EffectiveToTimeKey =@TimeKey
FROM dbo.AdvAcFinancialDetail  AS O
	INNER JOIN #AdvAcFinancialDetail AS T
ON O.AccountEntityID=T.AccountEntityID
	AND O.EffectiveFromTimeKey=@TimeKey AND O.EffectiveToTimeKey>=@TimeKey 
	AND O.EffectiveFromTimeKey =@TimeKey
 WHERE 
	(  
		ISNULL(O.NpaDt,'1900-01-01')   <> ISNULL(T.NpaDt,'1900-01-01')     
	)

UPDATE T SET T.IsChanged='D'
FROM DBO.AdvAcFinancialDetail  AS O
INNER JOIN #AdvAcFinancialDetail AS T
	ON  O.AccountEntityID=T.AccountEntityID
	AND O.EffectiveFromTimeKey =@TimeKey

/***************************************************************************************************************/


--  ----------For Changes Records
--UPDATE A SET A.IsChanged='C'
------Select * 
--from #AdvAcFinancialDetail A
--INNER JOIN DBO.AdvAcFinancialDetail B 
--ON B.AccountEntityId=A.AccountEntityId   
--Where B.EffectiveToTimeKey= @vEffectiveto
--And B.ModifiedBy='SSISUSERACL-MOC'




/*  New Customers EntityKey ID Update  */
--DECLARE @EntityKey INT
sET @EntityKey =0 
SELECT @EntityKey=MAX(EntityKey) FROM  [dbo].[AdvAcFinancialDetail] 
IF @EntityKey IS NULL  
BEGIN
SET @EntityKey=0
END
 
UPDATE TEMP 
SET TEMP.EntityKey=ACCT.EntityKey
 FROM #AdvAcFinancialDetail TEMP
INNER JOIN (SELECT AccountEntityId,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
			FROM #AdvAcFinancialDetail
			WHERE  ISNULL(IsChanged,'U')<>'D')ACCT ON TEMP.AccountEntityId=ACCT.AccountEntityId
---Where Temp.IsChanged in ('N','C')

----UPDATE A
----SET A.IsChanged='K' 
----FROM #AdvAcFinancialDetail A
----	INNER JOIN AdvAcFinancialDetail B
----		ON A.AccountEntityId =B.AccountEntityId
----		AND B.EffectiveFromTimeKey=@TIMEKEY AND B.EffectiveToTimeKey=@TIMEKEY

----		SELECT COUNT(1), AccountEntityId FROM #AdvAcFinancialDetail 
----		GROUP BY AccountEntityId
----		HAVING COUNT(1)>1

------------------------------------------------------------------


INSERT INTO DBO.AdvAcFinancialDetail
(	[ENTITYKEY]
      ,[AccountEntityId]
      ,[Ac_LastReviewDueDt]
      ,[Ac_ReviewTypeAlt_key]
      ,[Ac_ReviewDt]
      ,[Ac_ReviewAuthAlt_Key]
      ,[Ac_NextReviewDueDt]
      ,[DrawingPower]
      ,[InttRate]
      ,[NpaDt]
      ,[BookDebts]
      ,[UnDrawnAmt]
      ,[UnAdjSubSidy]
      ,[LastInttRealiseDt]
      ,[MocStatus]
      ,[MOCReason]
      ,[LimitDisbursed]
      ,[RefCustomerId]
      ,[RefSystemAcId]
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
      ,[MocDate]
      ,[MocTypeAlt_Key]
      ,[CropDuration]
      ,[Ac_ReviewAuthLevelAlt_Key]
	  ,AccountBlkCode2
           )
SELECT
	
	  ENTITYKEY
      ,AccountEntityId
      ,Ac_LastReviewDueDt
      ,Ac_ReviewTypeAlt_key
      ,Ac_ReviewDt
      ,Ac_ReviewAuthAlt_Key
      ,Ac_NextReviewDueDt
      ,DrawingPower
      ,InttRate
      ,NpaDt
      ,BookDebts
      ,UnDrawnAmt
      ,UnAdjSubSidy
      ,LastInttRealiseDt
      ,MocStatus
      ,MOCReason
      ,LimitDisbursed
      ,RefCustomerId
      ,RefSystemAcId
      ,AuthorisationStatus
      ,@TimeKey EffectiveFromTimeKey
      ,@TimeKey EffectiveToTimeKey
      ,CreatedBy
      ,DateCreated
      ,ModifiedBy
      ,DateModified
      ,ApprovedBy
      ,DateApproved
      ,getdate() D2Ktimestamp
      ,MocDate
      ,MocTypeAlt_Key
      ,CropDuration
      ,Ac_ReviewAuthLevelAlt_Key
	  ,AccountBlkCode2
	FROM #AdvAcFinancialDetail T Where ISNULL(T.IsChanged,'U') NOT IN ('D','K')




INSERT INTO DBO.AdvAcFinancialDetail
(	[ENTITYKEY]
      ,[AccountEntityId]
      ,[Ac_LastReviewDueDt]
      ,[Ac_ReviewTypeAlt_key]
      ,[Ac_ReviewDt]
      ,[Ac_ReviewAuthAlt_Key]
      ,[Ac_NextReviewDueDt]
      ,[DrawingPower]
      ,[InttRate]
      ,[NpaDt]
      ,[BookDebts]
      ,[UnDrawnAmt]
      ,[UnAdjSubSidy]
      ,[LastInttRealiseDt]
      ,[MocStatus]
      ,[MOCReason]
      ,[LimitDisbursed]
      ,[RefCustomerId]
      ,[RefSystemAcId]
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
      ,[MocDate]
      ,[MocTypeAlt_Key]
      ,[CropDuration]
      ,[Ac_ReviewAuthLevelAlt_Key]
	  ,AccountBlkCode2
           )
SELECT
	
	  ENTITYKEY
      ,AccountEntityId
      ,Ac_LastReviewDueDt
      ,Ac_ReviewTypeAlt_key
      ,Ac_ReviewDt
      ,Ac_ReviewAuthAlt_Key
      ,Ac_NextReviewDueDt
      ,DrawingPower
      ,InttRate
      ,NpaDt_org
      ,BookDebts
      ,UnDrawnAmt
      ,UnAdjSubSidy
      ,LastInttRealiseDt
      ,MocStatus
      ,MOCReason
      ,LimitDisbursed
      ,RefCustomerId
      ,RefSystemAcId
      ,AuthorisationStatus
      ,@TimeKey +1 EffectiveFromTimeKey
      ,EffectiveToTimeKey
      ,CreatedBy
      ,DateCreated
      ,ModifiedBy
      ,DateModified
      ,ApprovedBy
      ,DateApproved
      ,getdate() D2Ktimestamp
      ,MocDate
      ,MocTypeAlt_Key
      ,CropDuration
      ,Ac_ReviewAuthLevelAlt_Key
	  ,AccountBlkCode2
	FROM #AdvAcFinancialDetail T  Where  ISNULL(T.IsChanged,'U')<>'D'--IN ('N','C')
		and t.EffectiveToTimeKey>26267

INSERT INTO PreMoc.AdvAcFinancialDetail
(	 [AccountEntityId]
      ,[Ac_LastReviewDueDt]
      ,[Ac_ReviewTypeAlt_key]
      ,[Ac_ReviewDt]
      ,[Ac_ReviewAuthAlt_Key]
      ,[Ac_NextReviewDueDt]
      ,[DrawingPower]
      ,[InttRate]
      ,[NpaDt]
      ,[BookDebts]
      ,[UnDrawnAmt]
      ,[UnAdjSubSidy]
      ,[LastInttRealiseDt]
      ,[MocStatus]
      ,[MOCReason]
      ,[LimitDisbursed]
      ,[RefCustomerId]
      ,[RefSystemAcId]
      ,[AuthorisationStatus]
      ,[EffectiveFromTimeKey]
      ,[EffectiveToTimeKey]
      ,[CreatedBy]
      ,[DateCreated]
      ,[ModifiedBy]
      ,[DateModified]
      ,[ApprovedBy]
      ,[DateApproved]
      ,[MocDate]
      ,[MocTypeAlt_Key]
      ,[CropDuration]
      ,[Ac_ReviewAuthLevelAlt_Key]
	  ,AccountBlkCode2
           )
SELECT
		   T.AccountEntityId
      ,T.Ac_LastReviewDueDt
      ,T.Ac_ReviewTypeAlt_key
      ,T.Ac_ReviewDt
      ,T.Ac_ReviewAuthAlt_Key
      ,T.Ac_NextReviewDueDt
      ,T.DrawingPower
      ,T.InttRate
      ,NpaDt_org
      ,T.BookDebts
      ,T.UnDrawnAmt
      ,T.UnAdjSubSidy
      ,T.LastInttRealiseDt
      ,T.MocStatus
      ,T.MOCReason
      ,T.LimitDisbursed
      ,T.RefCustomerId
      ,T.RefSystemAcId
      ,T.AuthorisationStatus
      ,@TimeKey EffectiveFromTimeKey
      ,@TimeKey EffectiveToTimeKey
      ,T.CreatedBy
      ,T.DateCreated
      ,T.ModifiedBy
      ,T.DateModified
      ,T.ApprovedBy
      ,T.DateApproved
      ,T.MocDate
      ,T.MocTypeAlt_Key
      ,T.CropDuration
      ,T.Ac_ReviewAuthLevelAlt_Key
	  ,T.AccountBlkCode2
	FROM #AdvAcFinancialDetail T 
		left join PreMoc.ADVACFINANCIALDETAIL tt
			on tt.EffectiveFromTimeKey =@TimeKey and tt.EffectiveToTimeKey=@TimeKey
			AND tt.AccountEntityId =t.AccountEntityId
	Where tt.AccountEntityId is null
		
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

	ASSETCLASSALT_KEY_Org	TINYINT,
	BALANCE_Org				[decimal](16, 2) NULL,	 
	TOTALPROV_Org			[decimal](16, 2) NULL,
	PrincipalBalance_Org	[decimal](16, 2) NULL,

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

,ASSETCLASSALT_KEY_Org	
,BALANCE_Org				
,TOTALPROV_Org			
,PrincipalBalance_Org	

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
,b.EffectiveFromTimeKey
,b.EffectiveToTimeKey
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

,b.ASSETCLASSALT_KEY	ASSETCLASSALT_KEY_Org	
,b.BALANCE				BALANCE_Org				
,b.TOTALPROV			TOTALPROV_Org			
,b.PrincipalBalance		PrincipalBalance_Org	


From Pro.ACCOUNTCAL A
	INNER JOIN  Dbo.AdvAcBalanceDetail B 
ON A.AccountEntityID=B.AccountEntityId 
 	and b.EffectiveFromTimeKey<=@TimeKey  And B.EffectiveToTimeKey>=@TimeKey
 WHERE 
(  	   ISNULL(B.ASSETCLASSALT_KEY,0)    <> ISNULL(A.FINALASSETCLASSALT_KEY,0)    
	OR ISNULL(B.BALANCE,0)				<> ISNULL(A.BALANCE,0)      
	OR ISNULL(B.TOTALPROV,0)			<> ISNULL(A.TOTALPROVISION,0)     
	OR ISNULL(B.PrincipalBalance,0)     <> ISNULL(A.PrincOutStd,0) 
)


-----------------------------------------------------------------------------------------------------------------------------------------


UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSERACL-MOC'

From DBO.ADVACBALANCEDETAIL  AS O
	INNER JOIN #AdvAcBalanceDetail AS T
ON  O.AccountEntityID=T.AccountEntityID
	AND o.EffectiveFromTimeKey<=@TimeKey  And o.EffectiveToTimeKey>=@TimeKey
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
			O.ModifiedBy='SSISUSERACL-MOC',
			O.EffectiveToTimeKey =@TimeKey
From DBO.ADVACBALANCEDETAIL  AS O
	Inner Join #AdvAcBalanceDetail AS T
ON  O.AccountEntityID=T.AccountEntityID
	AND O.EffectiveFromTimeKey = @TimeKey and o.EffectiveToTimeKey>=@TimeKey
	
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
	AND O.EffectiveFromTimeKey = @TimeKey


----------For Changes Records
--UPDATE A SET A.IsChanged='C'
--from #AdvAcBalanceDetail A
--INNER JOIN DBO.AdvAcBalanceDetail B 
--ON B.AccountEntityId=A.AccountEntityId            
--Where B.EffectiveToTimeKey= @vEffectiveto
--And B.ModifiedBy='SSISUSERACL-MOC'


/*  New Customers EntityKey ID Update  */
SET @EntityKey =0 
SELECT @EntityKey=MAX(EntityKey) FROM  RBL_MISDB.[dbo].[AdvAcBalanceDetail] 
IF @EntityKey IS NULL  
BEGIN
SET @EntityKey=0
END
 
UPDATE TEMP 
SET TEMP.EntityKey=ACCT.EntityKey
 FROM #AdvAcBalanceDetail TEMP
INNER JOIN (SELECT AccountEntityId,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
			FROM #AdvAcBalanceDetail
			WHERE  ISNULL(IsChanged,'U')<>'D')ACCT ON TEMP.AccountEntityId=ACCT.AccountEntityId
 
--Where Temp.IsChanged in ('N','C')


/***************************************************************************************************************/

--UPDATE A
--SET A.IsChanged='K' 
--FROM #AdvAcBalanceDetail A
--	INNER JOIN AdvAcBalanceDetail B
--		ON A.AccountEntityId =B.AccountEntityId
--		AND B.EffectiveFromTimeKey=@TIMEKEY AND B.EffectiveToTimeKey=@TIMEKEY

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
			,@TimeKey EffectiveFromTimeKey
			,@TimeKey EffectiveToTimeKey
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
	   FROM #AdvAcBalanceDetail T  Where ISNULL(T.IsChanged,'U') NOT IN ('D','K')



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
		   )
	SELECT

		    EntityKey
			,AccountEntityId
			,ASSETCLASSALT_KEY_Org
			,BalanceInCurrency
			,BALANCE_Org
			,SignBalance
			,LastCrDt
			,OverDue
			,TOTALPROV_Org
			,RefCustomerId
			,RefSystemAcId
			,AuthorisationStatus
			,@TimeKey+1 EffectiveFromTimeKey
			,@TimeKey EffectiveToTimeKey
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
			,PrincipalBalance_Org
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
	   FROM #AdvAcBalanceDetail T  Where ISNULL(T.IsChanged,'U')<>'D'-- IN ('N','C')
		and EffectiveToTimeKey>@TimeKey

		INSERT INTO PreMoc.AdvAcBalanceDetail
		(	 AccountEntityId
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
			 
		   )
	SELECT

		    T.AccountEntityId
			,T.ASSETCLASSALT_KEY_Org
			,T.BalanceInCurrency
			,T.BALANCE_Org
			,T.SignBalance
			,T.LastCrDt
			,T.OverDue
			,T.TOTALPROV_Org
			,T.RefCustomerId
			,T.RefSystemAcId
			,T.AuthorisationStatus
			,@TimeKey+1 EffectiveFromTimeKey
			,@TimeKey EffectiveToTimeKey
			,T.OverDueSinceDt
			,T.MocStatus
			,T.MocDate
			,T.MocTypeAlt_Key
			,T.Old_OverDueSinceDt
			,T.Old_OverDue
			,T.ORG_TotalProv
			,T.IntReverseAmt
			,T.UnAppliedIntAmount
			,T.PS_Balance
			,T.NPS_Balance
			,T.DateCreated
			,T.ModifiedBy
			,T.DateModified
			,T.ApprovedBy
			,T.DateApproved
			,T.CreatedBy
			,T.UpgradeDate
			,T.OverduePrincipal
			,T.NotionalInttAmt
			,T.PrincipalBalance_Org
			,T.Overdueinterest
			,T.AdvanceRecovery
			,T.PS_NPS_FLAG
			,T.DFVAmt
			,T.InterestReceivable
			,T.OverduePrincipalDt
			,T.OverdueIntDt
			,T.OverOtherdue
			,T.OverdueOtherDt
			,T.SourceAssetClass
			,T.SourceNpaDate
			 
	   FROM #AdvAcBalanceDetail T  
		LEFT join premoc.AdvAcBalanceDetail b
			on b.EffectiveFromTimeKey=@TimeKey  and b.EffectiveToTimeKey=@TimeKey 
			and T.AccountEntityId=b.AccountEntityId
		WHERE B.AccountEntityId IS NULL

commit tran
end try
begin catch
	select ERROR_MESSAGE()
	rollback tran
end catch
/*        AdvAcBalanceDetail  END         */



GO