SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[Rpt-025]
	@TimeKey  INT,
	@SelectReport AS INT
	AS 


--DECLARE  @TimeKey AS INT=26936,
--         @SelectReport AS INT=1

---------------------------------------------------
--DECLARE @CurDate AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey) 

DECLARE @CurDate AS date=(SELECT Date FROM Automate_advances WHERE EXT_flg='Y') 
-----------------------------------------------
IF(OBJECT_ID('TEMPDB..#AccountLevelMOC_Mod')IS NOT NULL)
   DROP TABLE #AccountLevelMOC_Mod

SELECT *
INTO #AccountLevelMOC_Mod
FROM AccountLevelMOC_Mod
WHERE EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
	  AND ChangeField IS NOT NULL AND AuthorisationStatus='A'

OPTION(RECOMPILE)

CREATE NONCLUSTERED INDEX INX_AccountID ON #AccountLevelMOC_Mod(AccountID)
INCLUDE	(ChangeField,EffectiveFromTimekey,EffectiveToTimekey)

---------------------------------------------------
IF(OBJECT_ID('TEMPDB..#CustomerLevelMOC_Mod')IS NOT NULL)
   DROP TABLE #CustomerLevelMOC_Mod

SELECT *
INTO #CustomerLevelMOC_Mod
FROM CustomerLevelMOC_Mod
WHERE EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
	  AND ChangeField IS NOT NULL AND AuthorisationStatus='A'

OPTION(RECOMPILE)

CREATE NONCLUSTERED INDEX INX_CustomerEntityID2 ON #CustomerLevelMOC_Mod(CustomerEntityID)
INCLUDE	(ChangeField,EffectiveFromTimekey,EffectiveToTimekey)

-------------------------------------------
---------------------PreMOC_DATA----------------------


SELECT 

DISTINCT 

	'Post Moc' Moc_Status 
	--,CONVERT(VARCHAR(20),@CurDate,103)                                AS CurrentProcessingDate
	,CONVERT(VARCHAR(20),A.MOC_Dt,103)                                AS	CurrentProcessingDate
	---------RefColumns---------
	,H.SourceName
	,A.UCIF_ID
	,A.RefCustomerID                                                  AS CustomerID
	,F.CustomerName
	,A.CustomerAcID
	,A.FacilityType
	,CONVERT(VARCHAR(20),A.InitialNpaDt,103)                          AS InitialNpaDt
    ,CONVERT(VARCHAR(20),A.FinalNpaDt,103)                            AS FinalNpaDt
	,D.AssetClassName                                                 AS InitalAssetClassName	
	,E.AssetClassName                                                 AS FinalAssetClassName 
	,ISNULL(F.CurntQtrRv,0)                                           AS SecurityValue											      
	--,ISNULL(F.AddlProvisionPer,0)                                     AS AddlProvision									      
	,ISNULL(A.AddlProvisionPer,0)                                     AS AddlProvision
	----Edit--------
	,ISNULL(A.PrincOutStd,0)                                          AS PrincOutStd
    ,ISNULL(A.UnserviedInt,0)                                         AS UnserviedInt
	,ISNULL(A.AddlProvision,0)                                        AS AddlProvisionAbs
	,A.FlgFraud
	,CONVERT(VARCHAR(20),A.FraudDate,103)                             AS FraudDate
	,A.FlgFITL	
	,ISNULL(A.DFVAmt,0)                                               AS DFVAmt
	,CONVERT(VARCHAR(20),ALM.TwoDate,103)                             AS TWODate
	,ISNULL(ALM.TwoAmount,0)		                                  AS TWOAmount
										      
	--,CONVERT(VARCHAR(20),A.MOC_Dt,103)                                AS MOC_Dt
	,CONVERT(VARCHAR(20),@CurDate,103)									AS MOC_Dt
	,ISNULL(ALM.CreatedBy,CLM.CreatedBy)                              AS MakerID
	,CONVERT(VARCHAR(20),ISNULL(ALM.DateCreated,CLM.DateCreated),103)                          AS MakerDate
	,ISNULL(ALM.ApprovedByFirstLevel,CLM.ApprovedByFirstLevel)        AS CheckerID
	,CONVERT(VARCHAR(20),ISNULL(ALM.DateApprovedFirstLevel,CLM.DateApprovedFirstLevel),103)    AS CheckerDate
	,ISNULL(ALM.ApprovedBy,CLM.ApprovedBy)                            AS ReviewerID 
	,CONVERT(VARCHAR(20),ISNULL(ALM.DateApproved,CLM.DateApproved),103)                        AS ReviewerDate
	,ISNULL(A.MOCReason,F.MOCReason)                                  AS MOCReason

FROM  Pro.AccountCal_Hist A

INNER JOIN DimAssetClass E                    ON E.AssetClassAlt_Key=A.FinalAssetClassAlt_Key 
                                                 AND E.EffectiveFromTimeKey<=@TimeKey
												 AND E.EffectiveToTimeKey>=@TimeKey
                                                 AND A.EffectiveFromTimeKey<=@TimeKey
												 AND A.EffectiveToTimeKey>=@TimeKey

LEFT JOIN #AccountLevelMOC_Mod ALM            ON ALM.AccountId=A.CustomerAcID

LEFT JOIN Pro.CustomerCal_HIST F              ON F.CustomerEntityId=A.CustomerEntityId
                                                 AND F.EffectiveFromTimeKey<=@TimeKey
												 AND F.EffectiveToTimeKey>=@TimeKey

INNER JOIN DimSourceDB H                      ON H.SourceAlt_Key=A.SourceAlt_Key
                                                 AND H.EffectiveFromTimeKey<=@TimeKey
												 AND H.EffectiveToTimeKey>=@TimeKey

LEFT JOIN #CustomerLevelMOC_Mod CLM           ON F.CustomerEntityId=CLM.CustomerEntityId

LEFT JOIN DimAssetClass D                     ON D.AssetClassAlt_Key=A.InitialAssetClassAlt_Key 
                                                 AND D.EffectiveFromTimeKey<=@TimeKey
												 AND D.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimProduct C                        ON C.ProductAlt_Key=A.ProductAlt_Key 
                                                 AND C.EffectiveFromTimeKey<=@TimeKey
												 AND C.EffectiveToTimeKey>=@TimeKey




WHERE (A.FlgMoc='Y'  OR F.FlgMoc='Y') AND @SelectReport=1

UNION ALL

SELECT 

DISTINCT

    'Pre Moc' Moc_Status 
    --,CONVERT(VARCHAR(20),@CurDate,103)                                AS CurrentProcessingDate
	,CONVERT(VARCHAR(20),A.MOC_Dt,103)                                AS	CurrentProcessingDate
    ---------RefColumns---------
	,H.SourceName
	,A.UCIF_ID
	,A.RefCustomerID                                                  AS CustomerID
	,F.CustomerName
	,A.CustomerAcID
	,A.FacilityType
	,CONVERT(VARCHAR(20),A.InitialNpaDt,103)                          AS InitialNpaDt
    ,CONVERT(VARCHAR(20),A.FinalNpaDt,103)                            AS FinalNpaDt
	,D.AssetClassName                                                 AS InitalAssetClassName	
	,E.AssetClassName                                                 AS FinalAssetClassName 
	,ISNULL(F.CurntQtrRv,0)                                           AS SecurityValue											      
	--,ISNULL(F.AddlProvisionPer,0)                                     AS AddlProvision										      
	,ISNULL(A.AddlProvisionPer,0)                                     AS AddlProvision
	----Edit--------
	,ISNULL(A.PrincOutStd,0)                                          AS PrincOutStd
    ,ISNULL(A.UnserviedInt,0)                                         AS UnserviedInt
	,ISNULL(A.AddlProvision,0)                                        AS AddlProvisionAbs
	,A.FlgFraud
	,CONVERT(VARCHAR(20),A.FraudDate,103)                             AS FraudDate	
	,A.FlgFITL	
	,ISNULL(A.DFVAmt,0)                                               AS DFVAmt
	,CONVERT(VARCHAR(20),TWO.StatusDate,103)                          AS TWODate
	,ISNULL(TWO.Amount,0)		                                      AS TWOAmount	
														      
	--,CONVERT(VARCHAR(20),A.MOC_Dt,103)                                AS MOC_Dt	
	,CONVERT(VARCHAR(20),@CurDate,103)									AS MOC_Dt

	,ISNULL(ALM.CreatedBy,CLM.CreatedBy)                              AS MakerID
	,CONVERT(VARCHAR(20),ISNULL(ALM.DateCreated,CLM.DateCreated),103)                          AS MakerDate
	,ISNULL(ALM.ApprovedByFirstLevel,CLM.ApprovedByFirstLevel)        AS CheckerID
	,CONVERT(VARCHAR(20),ISNULL(ALM.DateApprovedFirstLevel,CLM.DateApprovedFirstLevel),103)    AS CheckerDate
	,ISNULL(ALM.ApprovedBy,CLM.ApprovedBy)                            AS ReviewerID 
	,CONVERT(VARCHAR(20),ISNULL(ALM.DateApproved,CLM.DateApproved),103)                        AS ReviewerDate
	,ISNULL(A.MOCReason,F.MOCReason)                                  AS MOCReason	

FROM PreMoc.AccountCal A
INNER JOIN DimAssetClass E                              ON E.AssetClassAlt_Key=A.FinalAssetClassAlt_Key 
                                                           AND E.EffectiveFromTimeKey<=@TimeKey
												           AND E.EffectiveToTimeKey>=@TimeKey
                                                           AND A.EffectiveFromTimeKey<=@TimeKey
												           AND A.EffectiveToTimeKey>=@TimeKey

LEFT JOIN #AccountLevelMOC_Mod ALM                      ON ALM.AccountId=A.CustomerAcID

LEFT JOIN PreMoc.CustomerCal F                          ON F.CustomerEntityId=A.CustomerEntityId
                                                           AND F.EffectiveFromTimeKey<=@TimeKey
												           AND F.EffectiveToTimeKey>=@TimeKey

LEFT JOIN #CustomerLevelMOC_Mod CLM                     ON F.CustomerEntityId=CLM.CustomerEntityId

LEFT JOIN (SELECT  CustomerID,ACID,StatusDate,ISNULL(Amount,0) Amount FROM  ExceptionFinalStatusType
                             WHERE StatusType='TWO'
                         AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) TWO
                               ON   A.CustomerACID=TWO.ACID 


INNER JOIN DimSourceDB H                                ON H.SourceAlt_Key=A.SourceAlt_Key
                                                           AND H.EffectiveFromTimeKey<=@TimeKey
												           AND H.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimAssetClass D                               ON D.AssetClassAlt_Key=A.InitialAssetClassAlt_Key 
                                                           AND D.EffectiveFromTimeKey<=@TimeKey
												           AND D.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimProduct C                                  ON C.ProductAlt_Key=A.ProductAlt_Key 
                                                           AND C.EffectiveFromTimeKey<=@TimeKey
												           AND C.EffectiveToTimeKey>=@TimeKey

WHERE A.CustomerAcID IN(SELECT CustomerAcID FROM Pro.AccountCal_Hist A
                                 LEFT JOIN Pro.CustomerCal_HIST C On C.CustomerEntityId=A.CustomerEntityId
                                WHERE (A.FlgMoc='Y' OR C.FlgMoc='Y') ) AND @SelectReport=1

ORDER BY CustomerAcID,CustomerID,Moc_Status DESC


OPTION(RECOMPILE)

DROP TABLE #AccountLevelMOC_Mod,#CustomerLevelMOC_Mod

GO