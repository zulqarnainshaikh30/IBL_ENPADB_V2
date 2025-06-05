SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



create PROCEDURE [dbo].[Rpt-030]
      @TimeKey AS INT,
	  @Cost    AS FLOAT
AS

--DECLARE 
--      @TimeKey AS INT=25992,
--	  @Cost    AS FLOAT=1

DECLARE @Date AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)

	---------------------------------Interest Reversal---------------------------------
	
SELECT 
CONVERT(VARCHAR(20),@Date, 103)                  AS  [Process_date] 
,A.UCIF_ID                                       AS UCIC
,A.RefCustomerID                                 AS CustomerID
,CustomerName
,B.BranchCode
,BranchName
,CustomerAcID
,SourceName
,B.FacilityType
,SchemeType
,B.ProductCode
,ProductName
,ActSegmentCode
,AcBuSegmentDescription
,AcBuRevisedSegmentCode
,DPD_Max
,CONVERT(VARCHAR(20),FinalNpaDt,103)              AS FinalNpaDt
,ISNULL(Balance,0)/@Cost                          AS Balance
,ISNULL(NetBalance,0)/@Cost                       AS NetBalance
,A2.AssetClassName                                AS FinalassetClass
,''                                               AS Asset_Class_Code
,ISNULL(IntOverdue,0)/@Cost                       AS [interest_Due]
,0                                                AS [Penal_Due]
,ISNULL(OtherOverdue,0)/@Cost                     AS [Other_Dues]
,0                                                AS [interest_receivable & accured interest]
,0                                                AS [penal_int_receivable]
,0                                                AS [interest_Outstanding]
,0                                                AS [Other_Charges_outstanding]
,0                                                AS [GST_Service_Tax_Outstanding]
,0                                                AS [Interest/Dividend Overdue Amount]
FROM PRO.CUSTOMERCAL A
INNER JOIN PRO.ACCOUNTCAL B   	    ON A.CustomerEntityID=B.CustomerEntityID
                                       AND A.EffectiveFromTimeKey<=@TimeKey
									   AND A.EffectiveToTimeKey>=@TimeKey
                                       AND B.EffectiveFromTimeKey<=@TimeKey
									   AND B.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DIMSOURCEDB src	        ON B.SourceAlt_Key =src.SourceAlt_Key	
                                       AND src.EffectiveFromTimeKey<=@TimeKey
									   AND src.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DIMPRODUCT PD       	    ON  PD.PRODUCTALT_KEY=B.PRODUCTALT_KEY
                                        AND PD.EffectiveFromTimeKey<=@TimeKey
									    AND PD.EffectiveToTimeKey>=@TimeKey
									   								    
LEFT JOIN DimAssetClass A2	        ON A2.AssetClassAlt_Key=B.FinalAssetClassAlt_Key
                                       AND A2.EffectiveFromTimeKey<=@TimeKey
									   AND A2.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimAcBuSegment S          ON B.ActSegmentCode=S.AcBuSegmentCode
                                       AND S.EffectiveFromTimeKey<=@TimeKey
									   AND S.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimBranch X               ON B.BranchCode = X.BranchCode
                                       AND X.EffectiveFromTimeKey<=@TimeKey
									   AND X.EffectiveToTimeKey>=@TimeKey

OPTION(RECOMPILE)

GO