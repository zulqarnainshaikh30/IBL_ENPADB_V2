SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



 CREATE PROC [dbo].[Rpt-032_BranchSelection]
      @FromDate  VARCHAR(20)
     ,@ToDate  VARCHAR(20)
  AS
 
 
 --DECLARE
 --     @FromDate  VARCHAR(20) ='31/05/2021' 
 --    ,@ToDate  VARCHAR(20)='30/06/2021'


-------------------------------------------------------------------------------
DECLARE	@FromDate1 DATE=(SELECT Rdate FROM dbo.DateConvert(@FromDate))
DECLARE @ToDate1 DATE=(SELECT Rdate FROM dbo.DateConvert(@ToDate))

DECLARE @FromTimeKey  AS INT=(SELECT TimeKey FROM SysDayMatrix WHERE DATE=@FromDate1)
DECLARE @ToTimeKey   AS INT=(SELECT TimeKey FROM SysDayMatrix WHERE DATE=@ToDate1)

--------------------------------------------------------------------------------

SELECT
BranchCode                             AS Code,
BranchCode+'-'+ISNULL(BranchName,'')   AS Label

FROM DimBranch  

WHERE EffectiveFromTimeKey<=@FromTimeKey AND EffectiveToTimeKey>=@FromTimeKey

UNION 

SELECT
BranchCode                             AS Code,
BranchCode+'-'+ISNULL(BranchName,'')   AS Label

FROM DimBranch  

WHERE EffectiveFromTimeKey<=@ToTimeKey AND EffectiveToTimeKey>=@ToTimeKey


ORDER BY Code

OPTION(RECOMPILE)

GO