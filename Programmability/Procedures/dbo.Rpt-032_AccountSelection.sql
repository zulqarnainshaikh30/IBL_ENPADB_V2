SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




 CREATE PROC [dbo].[Rpt-032_AccountSelection]
      @FromDate  VARCHAR(20)
     ,@ToDate  VARCHAR(20)
	 ,@BranchCode VARCHAR(MAX)
	 ,@CustomerID VARCHAR(100)

  AS
 
 
 --DECLARE
 --     @FromDate  VARCHAR(20) ='01/07/2021' 
 --    ,@ToDate  VARCHAR(20)='03/08/2021'
	-- ,@BranchCode VARCHAR(MAX)='2214'
	-- ,@CustomerID VARCHAR(100)='2214006313'

-------------------------------------------------------------------------------
DECLARE	@FromDate1 DATE=(SELECT Rdate FROM dbo.DateConvert(@FromDate))
DECLARE @ToDate1 DATE=(SELECT Rdate FROM dbo.DateConvert(@ToDate))

DECLARE @FromTimeKey  AS INT=(SELECT TimeKey FROM SysDayMatrix WHERE DATE=@FromDate1)
DECLARE @ToTimeKey   AS INT=(SELECT TimeKey FROM SysDayMatrix WHERE DATE=@ToDate1)

--------------------------------------------------------------------------------
SELECT
DISTINCT
CustomerAcID
FROM(
SELECT
CustomerAcID

FROM Pro.AccountCal_Hist   ACCOUNT        
INNER JOIN DimAssetClass   DA                   ON  ACCOUNT.FinalAssetClassAlt_Key=DA.AssetClassAlt_Key
                                                    AND DA.EffectiveFromTimeKey<=@FromTimeKey
												    AND DA.EffectiveToTimeKey>=@FromTimeKey
													AND ACCOUNT.EffectiveFromTimeKey<=@FromTimeKey
												    AND ACCOUNT.EffectiveToTimeKey>=@FromTimeKey

INNER JOIN DimBranch   DB                       ON ACCOUNT.BranchCode=DB.BranchCode
                                                   AND DB.EffectiveFromTimeKey<=@FromTimeKey
												   AND DB.EffectiveToTimeKey>=@FromTimeKey

WHERE  ---ISNULL(DA.AssetClassShortNameEnum,'') <> 'STD' AND
       DB.BranchCode IN (SELECT * FROM Dbo.Split(@BranchCode,',' ))
	   AND ACCOUNT.RefCustomerID=@CustomerID
	   
UNION ALL

SELECT
CustomerAcID

FROM Pro.AccountCal_Hist   ACCOUNT        

INNER JOIN DimAssetClass   DA                   ON  ACCOUNT.FinalAssetClassAlt_Key=DA.AssetClassAlt_Key
                                                    AND DA.EffectiveFromTimeKey<=@ToTimeKey
												    AND DA.EffectiveToTimeKey>=@ToTimeKey
                                                    AND ACCOUNT.EffectiveFromTimeKey<=@ToTimeKey
												    AND ACCOUNT.EffectiveToTimeKey>=@ToTimeKey

INNER JOIN DimBranch   DB                       ON ACCOUNT.BranchCode=DB.BranchCode
                                                   AND DB.EffectiveFromTimeKey<=@ToTimeKey
												   AND DB.EffectiveToTimeKey>=@ToTimeKey

WHERE  ---ISNULL(DA.AssetClassShortNameEnum,'') <> 'STD' AND
       DB.BranchCode IN (SELECT * FROM Dbo.Split(@BranchCode,',' ))
	   AND ACCOUNT.RefCustomerID=@CustomerID
)DATA

ORDER BY CustomerACID

OPTION(RECOMPILE)

GO