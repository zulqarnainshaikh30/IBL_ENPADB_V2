SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*

CREATE BY      :   Baijayanti
CREATE DATE    :   16-08-2022
DISCRIPTION    :   SMA Movement Report

*/

CREATE PROC [dbo].[Rpt-022] 
 @FromDate   AS VARCHAR(15)
,@ToDate     AS VARCHAR(15)
,@Disburse_Dt	AS	DATE 

AS

--DECLARE  @FromDate		AS VARCHAR(15)='01/02/2020'
--        ,@ToDate		AS VARCHAR(15)='07/02/2023'
--		,@Disburse_Dt	AS DATE		='2023-10-23'

DECLARE @From1  DATE=(SELECT Rdate FROM dbo.DateConvert(@FromDate))
DECLARE @To1   DATE=(SELECT Rdate FROM dbo.DateConvert(@ToDate))
DECLARE @TimeKey  AS INT=(SELECT TimeKey FROM SysDayMatrix WHERE DATE=@To1)


DECLARE @FromTimeKey INT=(SELECT TimeKey FROM Sysdaymatrix WHERE [DATE]=@From1)
DECLARE @ToTimeKey INT=(SELECT TimeKey FROM Sysdaymatrix WHERE [DATE]=@To1)

SELECT
DISTINCT
ACH.BranchCode,
AMH.CustomerACID,
CCH.RefCustomerID,
CustomerName,
MovementToStatus,
CONVERT(VARCHAR(20),ACH.SMA_Dt,103)                                                                     AS SMADate0,
CONVERT(VARCHAR(20),CASE WHEN ACH.SMA_Class IN ('SMA_1','SMA_2')      
                         THEN DATEADD(DD,30,ACH.SMA_Dt) 
						 END,103)                                                                       AS SMADate1,
CONVERT(VARCHAR(20), CASE WHEN ACH.SMA_Class='SMA_2' THEN DATEADD(DD,60,ACH.SMA_Dt) END,103)            AS SMADate2,
ProductCode,
ISNULL(TotOsAcc,0)                                 AS TotOsAcc,
AssetClassShortNameEnum
,CASE WHEN MovementToStatus <> MovementFromStatus THEN CONVERT(VARCHAR(20),MovementFromDate,103) END AS StatusAsOn
FROM Pro.ACCOUNT_MOVEMENT_HISTORY  AMH

INNER JOIN   Pro.AccountCal_Hist  ACH               ON ACH.CustomerACID=AMH.CustomerACID
                                                       AND ACH.EffectiveFromTimeKey<=@TOTimeKey AND ACH.EffectiveToTimeKey>=@FromTimeKey 

INNER JOIN Pro.CustomerCal_Hist   CCH               ON CCH.RefCustomerID=AMH.RefCustomerID
                                                       AND CCH.EffectiveFromTimeKey<=@TOTimeKey AND   CCH.EffectiveToTimeKey>=@FromTimeKey 

INNER JOIN DimAssetClass   DAC                      ON AMH.FinalAssetClassAlt_Key=DAC.AssetClassAlt_Key
                                                       AND DAC.EffectiveFromTimeKey<=@TOTimeKey AND   DAC.EffectiveToTimeKey>=@FromTimeKey


WHERE MovementFromDate<= @To1  AND MovementToDate  >= @From1  
      AND (MovementFromStatus IN('STD','SMA_0','SMA_1','SMA_2') AND MovementToStatus IN('SMA_0','SMA_1','SMA_2'))
	  AND	FirstDtOfDisb =@Disburse_Dt
            
			                                       
OPTION(RECOMPILE)


GO