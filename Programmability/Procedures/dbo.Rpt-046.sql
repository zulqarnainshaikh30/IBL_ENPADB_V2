SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Rpt-046] 
   @TimeKey   AS INT
AS

--DECLARE 
--   @TimeKey   AS INT=26479


DECLARE @CurDate AS DATE=(SELECT DATE FROM SysDayMatrix WHERE TimeKey=@TimeKey)

IF OBJECT_ID('tempdb..#AccountCal_Hist') IS NOT NULL 
	DROP TABLE #AccountCal_Hist

SELECT
 ACH.RefCustomerID
,ACH.UCIF_ID
,CCH.CustomerName
,SysNPA_Dt                                                         AS NPADate
,AssetClassName                                                    AS [Asset Classification]
,SUM(ISNULL(TotalProvision,0))                                     AS ProvisionAmount
,SUM(ISNULL(NetBalance,0))                                         AS NetBalanceProv
,(SUM(ISNULL(TotalProvision,0))/SUM(NULLIF(NetBalance,0)))*100     AS ProvisionPer
INTO #AccountCal_Hist
FROM Pro.AccountCal_Hist ACH   

INNER JOIN Pro.CustomerCal_Hist CCH              ON CCH.RefCustomerID=ACH.RefCustomerID
									             AND CCH.EffectiveFromTimeKey<=@TimeKey 
												 AND CCH.EffectiveToTimeKey>=@TimeKey
												 AND ACH.EffectiveFromTimeKey<=@TimeKey 
												 AND ACH.EffectiveToTimeKey>=@TimeKey

INNER JOIN DimAssetClass DAC                    ON DAC.AssetClassAlt_Key=CCH.SysAssetClassAlt_Key
                                                   AND DAC.EffectiveFromTimeKey<=@TimeKey 
												   AND DAC.EffectiveToTimeKey>=@TimeKey

GROUP BY
 ACH.RefCustomerID
,ACH.UCIF_ID
,CCH.CustomerName
,SysNPA_Dt 
,AssetClassName

OPTION(RECOMPILE)


SELECT DISTINCT
       ACH.UCIF_ID                                                             AS [UCIC_ID]
      ,RPPD.[CustomerID]										               
      ,ACH.CustomerName                                                        AS [CustomerName]
      ,DBRP.BankName											               
      ,BA.ArrangementDescription								               
      ,BRP.BankName                                                            AS LeadBank
	  ,CASE WHEN DefaultStatus='in defualt'
	        THEN CONVERT(VARCHAR(20),InDefaultDate,103)
			WHEN DefaultStatus='Out-Defualt'
			THEN CONVERT(VARCHAR(20),OutOfDefaultDate,103)
			END                                                                AS DefaultDate
	  ,DefaultStatus                                                           AS [RP_Status]
      ,EB.BucketName                                                           AS Bucketvalue
	  ,CONVERT(VARCHAR(20),ReferenceDate,103)                                  AS [ReferenceDate]
      ,CONVERT(VARCHAR(20),ReviewExpiryDate,103)                               AS [ReviewExpiryDate]
																               
      ,CONVERT(VARCHAR(20),RP_ApprovalDate,103)                                AS [RP_ApprovalDate]
      ,DPN.RPDescription                                                       AS [RP_Nature]
	  ,''                                                                      AS [AdviseNatureofRP]
																               
      ,CASE WHEN DATEDIFF(DD,RPPD.ReviewExpiryDate,@CurDate)<0		               
	        THEN ''												               
			ELSE DATEDIFF(DD,RPPD.ReviewExpiryDate,@CurDate)		               
			END																 AS [DaysPassedReviewPeriodDate]
      ,CONVERT(VARCHAR(20),RPPD.RP_ImplDate,103)                               AS [ResolutionPlanImplementationDate]
      ,DPI.ParameterName                                                       AS [ImplStatus]
      ,CONVERT(VARCHAR(20),Actual_Impl_Date,103)                               AS [Actual_Impl_Date]
      ,CASE WHEN DATEDIFF(DD,RPPD.RP_ImplDate,@CurDate)<0		               
	        THEN ''												               
			ELSE DATEDIFF(DD,RPPD.RP_ImplDate,@CurDate)		               
			END                                                                AS [DaysPassedResolutionImplementationDate]
	  ,CONVERT(VARCHAR(20),RP_OutOfDateAllBanksDeadline,103)                   AS [OutOfDefaultDate]
      ,CONVERT(VARCHAR(20),Revised_RP_Expiry_Date,103)                         AS [Revised_RP_Expiry_Date]
      ,case when rppd.RPNatureAlt_Key=1 then CONVERT(VARCHAR(20),RiskReviewExpiryDate,103) else '' end   AS [RiskReviewExpiryDate]
	  ,CASE WHEN IsBankExposure='Y'								               
	        THEN 'YES'											               
			WHEN IsBankExposure='N'								               
	        THEN 'NO'											               
			END                                                                AS [WhetherENBDExposure_Y_N]
      ,CONVERT(VARCHAR(20),ACH.NPADate,103)                                    AS NPADate
      ,case when ACH.[Asset Classification] ='los' then 'LOSS' else  ACH.[Asset Classification] end               AS [Asset Classification]
      ,ISNULL(ACH.ProvisionAmount,0)                                           AS ProvisionAmount
      ,ISNULL(ACH.NetBalanceProv,0)                                            AS NetBalanceProv
      ,ISNULL(ProvisionPer,0)                                                  AS ProvisionPer
      

  FROM RP_Portfolio_Details RPPD
  INNER JOIN RP_Lender_Details RPLD               ON RPPD.CustomerID=RPLD.CustomerID
                                                      AND RPPD.EffectiveFromTimeKey<=@TimeKey 
												      AND RPPD.EffectiveToTimeKey>=@TimeKey
													  AND RPLD.EffectiveFromTimeKey<=@TimeKey 
												      AND RPLD.EffectiveToTimeKey>=@TimeKey

  INNER JOIN #AccountCal_Hist ACH                 ON ACH.RefCustomerID=RPPD.CustomerID

  LEFT JOIN DimExposureBucket EB                  ON RPPD.ExposureBucketAlt_Key=EB.ExposureBucketAlt_Key
                                                     AND EB.EffectiveFromTimeKey<=@TimeKey 
												     AND EB.EffectiveToTimeKey>=@TimeKey
											       
  LEFT JOIN DimBankingArrangement BA              ON BA.BankingArrangementAlt_Key=RPPD.BankingArrangementAlt_Key
                                                     AND BA.EffectiveFromTimeKey<=@TimeKey 
												     AND BA.EffectiveToTimeKey>=@TimeKey
											       													  
  LEFT JOIN DimResolutionPlanNature  DPN	      ON RPPD.RPNatureAlt_Key=DPN.RPNatureAlt_Key
                                                     AND DPN.EffectiveFromTimeKey<=@TimeKey 
												     AND DPN.EffectiveToTimeKey>=@TimeKey
													  
													  												   
  LEFT JOIN DimParameter DPI                      ON RPPD.RP_ImplStatusAlt_Key=DPI.ParameterAlt_Key
                                                     AND DPI.EffectiveFromTimeKey<=@TimeKey 
												     AND DPI.EffectiveToTimeKey>=@TimeKey
													 AND DPI.DimParameterName='ImplementationStatus'
													  											       
  LEFT JOIN DimBankRP BRP                         ON BRP.BankRPAlt_Key=RPPD.LeadBankAlt_Key
                                                     AND BRP.EffectiveFromTimeKey<=@TimeKey 
												     AND BRP.EffectiveToTimeKey>=@TimeKey

  LEFT JOIN DimBankRP DBRP                        ON DBRP.BankRPAlt_Key=RPLD.ReportingLenderAlt_Key
                                                     AND DBRP.EffectiveFromTimeKey<=@TimeKey 
												     AND DBRP.EffectiveToTimeKey>=@TimeKey


ORDER BY RPPD.[CustomerID]

OPTION(RECOMPILE)

DROP TABLE #AccountCal_Hist
GO