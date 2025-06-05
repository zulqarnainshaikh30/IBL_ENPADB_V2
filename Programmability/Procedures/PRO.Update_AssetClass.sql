SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 

/*=========================================

AUTHER : TRILOKI KHANNA

alter DATE : 27-11-2019

MODIFY DATE : 27-11-2019

DESCRIPTION : UPDATE AssetClass

---EXEC [Pro].[Update_AssetClass] @TIMEKEY=25140

=============================================*/

 

CREATE PROCEDURE [PRO].[Update_AssetClass]

@TIMEKEY INT

AS

BEGIN

    SET NOCOUNT ON

  BEGIN TRY

    

 

DECLARE @SUB_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='SUB_Days' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

DECLARE @DB1_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB1_Days' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

DECLARE @DB2_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB2_Days' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

DECLARE @MoveToDB1 DECIMAL(5,2) =(SELECT cast(RefValue/100.00 as decimal(5,2))FROM PRO.refperiod where BusinessRule='MoveToDB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

DECLARE @MoveToLoss DECIMAL(5,2)=(SELECT cast(RefValue/100.00 as decimal(5,2)) FROM PRO.refperiod where BusinessRule='MoveToLoss' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

 

DECLARE @ProcessDate DATE =(SELECT DATE FROM SysDayMatrix WHERE TimeKey=@TIMEKEY)

 

IF OBJECT_ID('TEMPDB..#CTE_CustomerWiseBalance') IS NOT NULL

   DROP TABLE #CTE_CustomerWiseBalance

 

 

SELECT A.refcustomerid,SUM(ISNULL(A.BALANCE,0)) Balance

INTO #CTE_CustomerWiseBalance FROM PRO.ACCOUNTCAL A INNER JOIN PRO.CUSTOMERCAL B ON A.refcustomerid=B.refcustomerid

WHERE   ISNULL(B.FlgProcessing,'N')='N'

GROUP BY A.refcustomerid

 


create CLUSTERED INDEX I1 ON #CTE_CustomerWiseBalance(refcustomerid)

 

/*-----INTIAL LEVEL SysAssetClassAlt_Key DbtDt,C DegDate----------- */

 

UPDATE B SET B.DbtDt=NULL,B.LossDt=NULL,B.DegDate=NULL

FROM  #CTE_CustomerWiseBalance a   INNER JOIN PRO.CustomerCal B ON A.REFCUSTOMERID=B.REFCUSTOMERID

WHERE (ISNULL(B.FlgDeg,'N')='Y'  AND ISNULL(B.FlgProcessing,'N')='N' )

 

 

/*---CALCULATE SysAssetClassAlt_Key ,DbtDt,DegDate-----------------------*/

 

UPDATE B SET B.SysAssetClassAlt_Key= (--CASE WHEN    B.CurntQtrRv< (A.BALANCE *@MoveToLoss) THEN   (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='LOS' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

                                        CASE  WHEN  DATEADD(DAY,@SUB_Days,B.SysNPA_Dt)>@ProcessDate   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='SUB' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

                                                                                                                                                                  WHEN  DATEADD(DAY,@SUB_Days,B.SysNPA_Dt)<=@ProcessDate AND  DATEADD(DAY,@SUB_Days+@DB1_Days,B.SysNPA_Dt)>@ProcessDate   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

                                                                                                                                                      WHEN  DATEADD(DAY,@SUB_Days+@DB1_Days,B.SysNPA_Dt)<=@ProcessDate AND  DATEADD(DAY,@SUB_Days+@DB1_Days+@DB2_Days,B.SysNPA_Dt)>@ProcessDate THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB2' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

                                                                                                                                                       WHEN  DATEADD(DAY,(@DB1_Days+@SUB_Days+@DB2_Days),B.SysNPA_Dt)<=@ProcessDate  THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB3' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

                                                                                                                                                   END)

          ,B.DBTDT= (CASE

                                                                                                                                                       WHEN  DATEADD(DAY,@SUB_Days,B.SysNPA_Dt)<=@ProcessDate AND  DATEADD(DAY,@SUB_Days+@DB1_Days,B.SysNPA_Dt)>@ProcessDate  THEN DATEADD(DAY,@SUB_Days,B.SysNPA_Dt)

                                                                                                                                                       WHEN  DATEADD(DAY,@SUB_Days+@DB1_Days,B.SysNPA_Dt)<=@ProcessDate AND  DATEADD(DAY,@SUB_Days+@DB1_Days+@DB2_Days,B.SysNPA_Dt)>@ProcessDate   THEN DATEADD(DAY,@SUB_Days,B.SysNPA_Dt)

                                                                                                                                                       WHEN  DATEADD(DAY,(@DB1_Days+@SUB_Days+@DB2_Days),B.SysNPA_Dt)<=@ProcessDate THEN DATEADD(DAY,(@SUB_Days),B.SysNPA_Dt)

                                                                                                                                                                   ELSE DBTDT

                                                                                                                                                   END)

 

                                --,B.LossDt= (CASE  WHEN     B.CurntQtrRv< (A.BALANCE *@MoveToLoss)   THEN @PROCESSDATE ELSE LossDt END)

                                ,B.DegDate=@ProcessDate

 

FROM  #CTE_CustomerWiseBalance A   INNER JOIN PRO.CustomerCal B ON A.REFCUSTOMERID=B.REFCUSTOMERID

WHERE (ISNULL(B.FlgDeg,'N')='Y'    AND B.FlgProcessing='N' )

 

/*-------------MARKING OF FRAUD-----------------------*/

UPDATE  A SET A.SysAssetClassAlt_Key=

(SELECT  TOP 1 AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='LOS' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

FROM PRO.CustomerCal A

WHERE (

   ISNULL(A.SplCatg1Alt_Key,0) =870

OR ISNULL(A.SplCatg2Alt_Key,0) =870

OR ISNULL(A.SplCatg3Alt_Key,0)=870

OR ISNULL(A.SplCatg4Alt_Key,0)=870

)

AND ISNULL(A.FlgDeg,'N')='Y'

 

 

 

/*-------- UPDATE DBT DATE NULL FOR LOS CUSTOMERS------------------- */

UPDATE B SET DbtDt=NULL

FROM  #CTE_CustomerWiseBalance A   INNER JOIN PRO.CustomerCal B ON A.REFCUSTOMERID=B.REFCUSTOMERID

WHERE (ISNULL(B.FlgDeg,'N')='Y'  AND ISNULL(B.FlgProcessing,'N')='N' ) AND SysAssetClassAlt_Key IN(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='LOS' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

 

/*----UPDATE FINALASSETALT_KEY IN ACCOUNT LEVEL FROM CUSTOMER--------------------*/

 

UPDATE A SET A.FinalAssetClassAlt_Key=B.SysAssetClassAlt_Key

FROM PRO.AccountCal  A INNER JOIN PRO.CustomerCal B ON A.REFCUSTOMERID=B.REFCUSTOMERID

WHERE (ISNULL(B.FlgDeg,'N')='Y'  AND ISNULL(B.FlgProcessing,'N')='N' ) AND

(ISNULL(A.Asset_Norm,'NORMAL')='NORMAL' AND ISNULL(A.FlgDeg,'N')='Y')

 

 

 DROP TABLE #CTE_CustomerWiseBalance

  Exec Pro.Final_AssetClass_Npadate @timekey=@TIMEKEY,@FlgPreErosion='Y'


UPDATE PRO.ACLRUNNINGPROCESSSTATUS

                SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1

                WHERE RUNNINGPROCESSNAME='Update_AssetClass'

 

                -----------------Added for DashBoard 04-03-2021

--Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

 

END TRY

BEGIN  CATCH

 

                UPDATE PRO.ACLRUNNINGPROCESSSTATUS

                SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1

                WHERE RUNNINGPROCESSNAME='Update_AssetClass'

END CATCH

 

SET NOCOUNT OFF

END

 

 

 

 

 

 

 

 

 

 

 

 

 

GO